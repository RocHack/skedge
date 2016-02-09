(function() {
  var ReactUpdate = React.addons.update;

  window.SKScheduleAction = Reflux.createActions([
    'loadSchedulesAndBookmarks',
    'temporaryizeSection',
    'untemporaryizeSection',
    'commitSection',
    'changeSchedule',
    'getConflicts',
    'changeBookmark',
    'loadUser'
  ]);

  window.SKScheduleStore = Reflux.createStore({
    listenables: [SKScheduleAction],

    getInitialState: function() {
      var existingState = this.state || {};
      this.state = {
        schedule: existingState.schedule,
        schedules: existingState.schedules || {},
        pretempYrTerm: existingState.pretempYrTerm,

        temporaryAdds: [],
        temporaryDeletes: [],
        temporaryGhosts: [],

        readds: {},
        shouldRerenderResults: false,

        bookmarks: existingState.bookmarks || []
      };

      return this.state;
    },

    load: function (props, shouldRerenderResults) {
      if (props) {
        for (key in props) {
          this.state[key] = props[key];
        }
        this.state.shouldRerenderResults = shouldRerenderResults;
        this.trigger(this.state);
      }
    },

    loadSchedulesAndBookmarks: function(schedules, defaultSchedule, bookmarks) {
      this.state.schedules = schedules;
      this.state.bookmarks = bookmarks || [];
      this.changeSchedule(defaultSchedule, true);
    },

    changeBookmark: function(course) {
      var idx = this.state.bookmarks.findIndex(function (bk) {
        return bk.id == course.id;
      });

      var bookmarks;
      if (idx < 0) {
        bookmarks = this.state.bookmarks.concat(course);
      } else {
        bookmarks = ReactUpdate(this.state.bookmarks, {$splice: [[idx, 1]]});
      }
      this.load({bookmarks: bookmarks}, course.id);

      var self = this;
      $.post("bookmark", {course_id:course.id}, function (response) {
        //success
        self.loadUser(response.userSecret);
      }).fail(function (response) {
        //failure
        //undo everything in data!
        alert("failure :(");
      });
    },

    changeSchedule: function(yrTerm, rerender=false) {
      this.load({schedule: this.state.schedules[yrTerm], pretempYrTerm: yrTerm}, rerender);
    },

    temporaryizeSection: function(section) {
      //we might need to switch schedules (if it's a different term)
      //save the yrTerm, create a new schedule if needed, and switch to it
      var yrTerm = section.course.yrTerm;
      if (this.state.schedule) {
        this.state.pretempYrTerm = this.state.schedule.yrTerm;
      }
      if (!this.state.schedules[yrTerm]) {
        // New, temporary schedule
        this.state.schedules[yrTerm] = {
          yrTerm: yrTerm,
          term: section.course.term,
          year: section.course.year,
          sections: []
        };
      }
      this.state.schedule = this.state.schedules[yrTerm];

      var conflicts = this.getConflicts(section);

      if (conflicts == null) { //already added, so "remove" it
        this.state.temporaryDeletes.push(section);
      }
      else { //"add" it
        this.state.temporaryAdds.push(section);
        if (conflicts.length > 0) {
          //"remove" any conflicts
          var self = this;
          conflicts.some(function(conflict) {
            self.state.temporaryDeletes.push(conflict);
          });
        }
      }

      this.state.shouldRerenderResults = false;

      this.trigger(this.state);
    },

    untemporaryizeSection: function(section) {
      //undo everything in the method above, basically
      this.load({
        schedule: this.state.schedules[this.state.pretempYrTerm],
        temporaryAdds: [],
        temporaryDeletes: [],
        temporaryGhosts: []
      }, false);
    },

    readds: function(section, fromReadd, conflicts) {
      // calculate readds
      var readds = {};

      // copy all readds from before, minus this one
      for (sectionCRN in this.state.readds) {
        var readdsPerSection = this.state.readds[sectionCRN];
        for (var i = 0; i < readdsPerSection.length; i++) {
          if (readdsPerSection[i].crn != section.crn) {
            if (!readds[sectionCRN]) {
              readds[sectionCRN] = [];
            }
            readds[sectionCRN].push(readdsPerSection[i]);
          }
        }
      }

      // calculate any new readds to place, if it wasn't from a readd
      if (!fromReadd) {
        if (conflicts && conflicts.length > 0) {
          if (!readds[section.crn]) {
            readds[section.crn] = [];
          }
          readds[section.crn] = readds[section.crn].concat(conflicts);
        }
      }

      return readds;
    },   

    commitSection: function(section, fromReadd, originalFromReaddSection) {
      //full switch to this (don't undo when we unhover)
      this.state.pretempYrTerm = section.course.yrTerm;

      var ajaxBody = {};

      var conflicts = this.getConflicts(section);

      if (conflicts == null) {
        if (section.sectionType == MAIN) {
          this.state.schedule.totalCredits -= parseInt(section.course.credits);
        }

        //removing it
        var idx = -1;
        while (this.state.schedule.sections[++idx].crn != section.crn);
        this.state.schedule.sections.splice(idx, 1);

        ajaxBody[section.crn] = -1;
      }
      else {
        if (section.sectionType == MAIN) {
          this.state.schedule.totalCredits += parseInt(section.course.credits);
        }

        //adding it
        this.state.schedule.sections.push(section);
        ajaxBody[section.crn] = 1;

        //remove any conflicts
        var self = this;
        conflicts.some(function (conflict) {
          var idx = -1;
          while (self.state.schedule.sections[++idx].crn != conflict.crn);
          self.state.schedule.sections.splice(idx, 1);
          ajaxBody[conflict.crn] = -1;
        });
      }

      var newReadds = this.readds(section, fromReadd, conflicts);

      this.load({
        temporaryAdds: [],
        temporaryGhosts: [],
        temporaryDeletes: [],
        readds: newReadds
      }, originalFromReaddSection.course.id); //update only that button for perceived speedup

      // the rest of the results will be updated when the ajax is done

      this.courseAjax(ajaxBody);
    },

    loadUser: function(userSecret) {
      //store the secret in a cookie
      var d = new Date();
      d.setTime(d.getTime() + (4*365*24*60*60*1000));
      document.cookie = "s_id=x&"+userSecret+"; expires="+d.toUTCString()+"; domain=.skedgeur.com";
    },

    courseAjax: function(data) {
      var self = this;
      $.post("add_drop_sections", {data:data},
        function (response)
        {
          //success
          self.loadUser(response.userSecret);

          //update schedule
          self.load({
            schedules: response.schedules,
            schedule: response.schedules[self.state.pretempYrTerm]},
            true);
        }
        ).fail(function (response)
        {
          //failure
          //undo everything in data!
          alert("failure :(");
        }
        );
    }
  });

  window.SKScheduleStore.existsConflict = function(s1, s2, day) {
    if (s1.days && s2.days) {
      var overlap = function(day) {
        return s2.days.indexOf(day) > -1;
      };
      var dayOverlap = day ? overlap(day) : s1.days.split("").some(overlap);
      if (dayOverlap) {
        return ((s1.startTime >= s2.startTime && s1.startTime < s2.endTime) || 
                (s1.endTime > s2.startTime && s1.endTime <= s2.endTime)) ||
               ((s2.startTime >= s1.startTime && s2.startTime < s1.endTime) || 
                (s2.endTime > s1.startTime && s2.endTime <= s1.endTime));
      }
    }
    return false;
  };

  window.SKScheduleStore.sectionConflict = function(section, sections, day) {
    var conflicts = [];
    for (var i = 0; i < sections.length; i++) {
      if (sections[i].crn == section.crn) {
        return null;
      }
      if (this.existsConflict(section, sections[i], day)) {
        conflicts.push(sections[i]);
      }
    }
    return conflicts;
  };

  window.SKScheduleStore.getConflicts = function(section) {
    var schedule;
    if (schedule = this.state.schedules[section.course.yrTerm]) {
      return this.sectionConflict(section, schedule.sections);
    }
    return [];
  };
})();