(function() {
  var ReactUpdate = React.addons.update;

  window.SKSocialAction = Reflux.createActions([
    'initializeSocial',
    'load',

    'acceptRequest',
    'sendRequest',
    'unshare',

    'changePrivacy'
  ]);

  window.SKSocialStore = Reflux.createStore({
    listenables: [SKSocialAction],

    getInitialState: function() {
      this.state = {
        ready: false,
        loggedIn: false,
        fb_id: null,

        requests: [],
        requested: [],

        friends: [],
        friendNames: {},
        shareUsers: [],
        publicFriends: [],
        otherFriends: [],

        likes: [],
        privacy: null,

        friendCount: 0
      };

      return this.state;
    },

    load: function (socialState) {
      // socialState includes:
      // requests, requested, shareUsers, likes, privacy
      if (socialState) {
        for (key in socialState) {
          this.state[key] = socialState[key];
        }
        var self = this;
        this.state.otherFriends = this.state.friends.filter(function (friend) {
          var r = self.state.requests.some(function (req) { return req.from == friend.id; });
          var s = self.state.shareUsers.some(function (sf) { return sf.fb_id == friend.id; });
          var p = self.state.publicFriends.some(function (pf) { return pf.fb_id == friend.id; });
          return !r && !s && (!p || self.state.privacy == 1);
        });
        this.trigger(this.state);
      }
    },

    initializeSocial: function () {
      // So it can be accessed by the SDK
      window.afterLogIn = this.checkLoginState;
      var self = this;

      window.fbAsyncInit = function() {
        FB.init({
          appId      : isDevReact() ? '554168138087623' : '538742782963492',
          xfbml      : true,
          version    : 'v2.5'
        });

        self.checkLoginState();
      };

      (function(d, s, id){
         var js, fjs = d.getElementsByTagName(s)[0];
         if (d.getElementById(id)) {return;}
         js = d.createElement(s); js.id = id;
         js.src = "//connect.facebook.net/en_US/sdk.js";
         fjs.parentNode.insertBefore(js, fjs);
       }(document, 'script', 'facebook-jssdk'));
    },

    checkLoginState: function () {
      var self = this;
      FB.getLoginStatus(function(response) {
        if (response.status == 'connected') {
          //The person is logged into Facebook, and has logged into your app
          var id = response.authResponse.userID;
          FB.api(
            "/"+id,
            function (response) {
              if (response && !response.error) {
                self.state.friendNames[id] = response.name;
                self.load({}); //reload otherFriends & notify
              }
            }
          );

          //signing in under different FB account than we thought, or is first time
          if (self.state.fb_id != id)
          {
            self.state.fb_id = id;
            $.post("social/register_user", {"id":id}, function (response) {
              SKScheduleAction.loadUser(response.user);
              self.load(response.social);
            });
          }
          self.state.loggedIn = true;
          self.trigger(self.state);

          self.getFriendsList();
        }
        else {
          if (self.state.loggedIn)
          {
            alert("Just FYI, logging out won't unlink your Skedge account with Facebook. To do this, you have to remove the app from Facebook itself.");
            //if was previously logged in, was a logout
            //just refresh, since the button won't let you log back in
            //bc fb is dumb
            window.location.reload();
          }
          self.state.loggedIn = false;
          self.state.ready = true;
          self.trigger(self.state);

          if (document.cookie.indexOf("social_popup") == -1) {
            var html = $('#social-callout').html();
            $('#social-callout').remove();

            $('.searchbar-globe').popover({container: 'body', html: true, content: html});
            $('.searchbar-globe').popover('show');

            $('#social-callout-dismiss').click(function (e) {
              document.cookie = "social_popup=true;";
              $('.searchbar-globe').popover('hide');
              e.preventDefault();
            });

            $('#social-callout-tryit').click(function (e) {
              document.cookie = "social_popup=true;";
              document.location = "/social";
            });
          }

          if (response.status == 'not_authorized') {
          //The person is logged into Facebook, but has not logged into your app.
          }
          else if (response.status == 'unknown') {
            //The person is not logged into Facebook, so you don't know if they've logged into your app
          }
        } 
      });
    },

    getFriendsList: function() {
      var self = this;
      FB.api("/me/friends",
        function (response)
        {
          if (response && !response.error) {
            for (var i = 0; i < response.data.length; i++) {
              var user = response.data[i];
              self.state.friendNames[user.id] = user.name;
            }

            self.load({friends: response.data, ready: true});

            $.get('social/get_public_sharing_friends', {
                friends: response.data,
                updateFriendCount: (window.location.pathname == "/social")
              }, function (resp) {
                self.load({publicFriends: resp.friends});
            })
          }
        }
      );
    },

    acceptRequest: function(req) {
      var self = this;
      $.post('social/share_accept', {sr_id:req.id, friends: this.state.friends}, function (data) {
        self.load({
          requests: data.requests,
          publicFriends: data.publicFriends,
          shareUsers: data.shareUsers
        });
      });
    },

    sendRequest: function(friend) {
      var self = this;
      $.post("social/share_request", {a: this.state.fb_id, b: friend.id}, function (data) {
        self.load({requested: data.requested});
      });
    },

    unshare: function(friend_id) {
      var self = this;
      $.post("social/unshare", {nonfriend: friend_id, friends: this.state.friends}, function (data) {
        self.load({shareUsers: data.shareUsers, publicFriends: data.publicFriends})
      });
    },

    changePrivacy: function(option) {
      var self = this;
      $.post("social/change_privacy", {option: option}, function (data) {
        self.load({privacy: option});
      });
    }
  });
})();