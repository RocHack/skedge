(function() {
  var ReactUpdate = React.addons.update;

  window.SKSocialAction = Reflux.createActions([
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
        privacy: null
      };

      window.SKSocialStoreSingleton = this;

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

    init: function () {
      // So it can be accessed by the SDK
      window.afterLogIn = this.checkLoginState;
      var self = this;

      window.fbAsyncInit = function() {
        FB.init({
          appId      : '538742782963492',
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
          self.state.loggedIn = false;
          self.state.ready = true;
          self.trigger(self.state);

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

            var event = new CustomEvent("gotFriendsList");
            document.dispatchEvent(event);

            $.get('social/get_public_sharing_friends', {friends: response.data}, function (resp) {
              self.load({publicFriends: resp.friends});
            })
          }
        }
      );
    },

    acceptRequest: function(req) {
      var self = this;
      $.post('social/share_accept', {sr_id:req.id, friends: this.state.friends}, function (data) {
        var index = self.state.requests.indexOf(req);
        self.load({
          requests: ReactUpdate(self.state.requests, {$splice: [[index, 1]]}),
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