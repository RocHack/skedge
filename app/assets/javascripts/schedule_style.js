var ScheduleStyle = {
  getBlockStyle: function (layout, section, day, dayIdx, color, us, them, conflicts) {
    var width = 100.0/layout.daysOfWeek.length - 1/4;
    var hour = 100/(layout.max-layout.min + 1);

    var height = section.duration * hour;
    var left = dayIdx*width;
    var top = hour * (section.startTimeHours - layout.min);
    var fontColor = "#FFFFFF";
    var borderWidth = "0px";

    var time = section.prettyTime;
    var fontSize = "1em";

    if (section.sectionType != MAIN) {
      if (height < 7.75) {
        fontSize = "0.9em";
      }
    }
    
    if (them && (conflicts == null || conflicts.length > 0)) {
      width = width/2 - 1/4;
      time = "";
    }

    if (us) {
      borderWidth = "1px";
      fontColor = "#191919";
      color = "#FFFFFF";

      if (conflicts == null || conflicts.length > 0) {
        width = width/2 - 1/4;
        left += width + 1/2;
        time = "";
        if (conflicts == null) {
          color = "#FBF8D8";
        }
      }
    }

    return {
      borderWidth: borderWidth,
      color: fontColor,
      width: width+"%",
      left: left+"%",
      top: top+"%",
      height: height+"%",
      backgroundColor: color,
      marginLeft: dayIdx/2+"%",
      marginRight: dayIdx/2+"%",
      fontSize: fontSize,
      time: time
    };
  },

  getLayout: function (props, state) {
    if (!props.schedule) {
      return {
        daysOfWeek: ["M", "T", "W", "R", "F"],
        hoursRange: [8, 9, 10, 11, 12, 13, 14, 15, 16],
        min: 8,
        max: 16
      };
    }
    else if (!state.comparingSchedule) {
      return this.getScheduleLayout(props.schedule.sections, props.temporaryAdds, props.temporaryGhosts);
    }
    else {
      return this.getScheduleLayout(props.schedule.sections.concat(props.userSchedule.sections));
    }
  },

  getScheduleLayout: function (sections, temporaryAdds, temporaryGhosts) {
    var daysOfWeek = ["M", "T", "W", "R", "F"];

    var min = 2500;
    var max = -1;

    var hasSat = false;
    var hasSun = false;

    if (temporaryAdds) {
      sections = sections.concat(temporaryAdds);
    }
    if (temporaryGhosts)  {
      sections = sections.concat(temporaryGhosts);
    }
    sections.forEach(function(section) {
      var start = (section.startTime-30)/100;
      var end = (section.endTime+30)/100;
      if (start < min) {
        min = start;
      }
      if (end > max) {
        max = end;
      }
      if (section.days.indexOf('S') > -1) {
        hasSat = true;
      }
      if (section.days.indexOf('U') > -1) {
        hasSun = true;
      }
    });
    
    var diff = max-min;
    var min_hrs = 7;
    if (diff < min_hrs) {
      min -= (min_hrs-diff)/2;
      max += (min_hrs-diff)/2;
    }

    min = Math.floor(min);
    max = Math.ceil(max);

    hoursRange = [];
    for (var i = min; i <= max; i++) {
      hoursRange.push(i);
    }

    if (hasSat) {
      daysOfWeek.push("S");
    }
    if (hasSun) {
      daysOfWeek = ["U"].concat(daysOfWeek);
    }

    return {
      daysOfWeek: daysOfWeek,
      hoursRange: hoursRange,
      min: min,
      max: max
    };
  }
};