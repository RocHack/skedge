var CLIENT_ID = "410824119771-h8mp1bd944i8j4r6gr3rifobh00trd16.apps.googleusercontent.com";
var SCOPES = ["https://www.googleapis.com/auth/calendar"];

function gcal_isAuthorized() {
  return gapi.client.calendar != null;
}

function checkAuth() {
  gcal_authorize(true);
}

function gcal_authorize(immediate, callback) {
  gapi.auth.authorize(
    {client_id: CLIENT_ID,
     scope: SCOPES,
     immediate: immediate,
     cookie_policy: 'single_host_origin'},
    function (token) {
      if (!token.error) {
        gapi.client.load('calendar', 'v3', function () {
          if (callback)
            callback(true);
        });
      }
    }
  );
}

function gcal_createSkedgeCalendar(name, completion) {
  var request = gapi.client.calendar.calendars.insert({summary: name});

  request.execute(function(cal) {
    completion(cal);
  });
}

function gcal_calendarList(completion) {
  var request = gapi.client.calendar.calendarList.list();
  request.execute(function(e) {
    completion(e.items);
  });
}

function gcal_createEvents(calId, scheduleId, completion) {
  $.get('/'+scheduleId+'.gcal', function (data) {
    for (var i = data.sections.length - 1; i >= 0; i--) {
      var request = gapi.client.calendar.events.insert({
        'calendarId': calId,
        'resource': data.sections[i]
      });

      request.execute(function(e) {
        completion(e);
      });
    };
  }).fail(function () {
    console.log(".gcal export fail?");
  });
}
