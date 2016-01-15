window.fbAsyncInit = function() {
  FB.init({
    appId      : '538742782963492',
    xfbml      : true,
    version    : 'v2.5'
  });

  checkLoginState();
};

(function(d, s, id){
   var js, fjs = d.getElementsByTagName(s)[0];
   if (d.getElementById(id)) {return;}
   js = d.createElement(s); js.id = id;
   js.src = "//connect.facebook.net/en_US/sdk.js";
   fjs.parentNode.insertBefore(js, fjs);
 }(document, 'script', 'facebook-jssdk'));

function checkLoginState() {
  FB.getLoginStatus(function(response) {
    console.log(response.status);
    if (response.status == 'connected') {
      //The person is logged into Facebook, and has logged into your app
      console.log("user id = "+response.authResponse.userID);
    }
    else if (response.status == 'not_authorized') {
      //The person is logged into Facebook, but has not logged into your app.
    }
    else if (response.status == 'unknown') {
      //The person is not logged into Facebook, so you don't know if they've logged into your app
    }
  });
}

function shareSchedules() {
  FB.api(
      "/me/friends",
      function (response) {
        if (response && !response.error) {
          console.log("pick:");
          response.data.map(function(user) {
            console.log(user);
            console.log("Request to share schedules with "+user.name);
          });
        }
      }
  );
}