(function() {
  var ReactUpdate = React.addons.update;

  window.SKSocialAction = Reflux.createActions([
    'load',

    'acceptRequest',
    'sendRequest',
    'unshare'
  ]);

  window.SKSocialStore = Reflux.createStore({
    listenables: [SKSocialAction],

    getInitialState: function() {
      this.state = {
        checkedLoginState: false,
        fb_id: null,

        requests: [],
        requested: [],

        friends: [],
        shareUsers: [],
        publicFriends: [],
        otherFriends: [],

        likes: [],
        privacy: null
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
        this.state.otherFriends = !this.state.fb_id || !window.FBID2Name ? [] : this.state.friends.filter(function (friend) {
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
                if (!window.FBID2Name) {
                  window.FBID2Name = {};
                }
                window.FBID2Name[id] = response.name;
              }
            }
          );

          $.post("social/register_user", {"id":id}, function (response) {
            SKScheduleAction.loadUser(response.user);
            self.load(response.social);
          });

          self.state.fb_id = id;

          self.getFriendsList();
        }
        else {
          self.state.fb_id = null;

          if (response.status == 'not_authorized') {
          //The person is logged into Facebook, but has not logged into your app.
          }
          else if (response.status == 'unknown') {
            //The person is not logged into Facebook, so you don't know if they've logged into your app
          }
        } 
        self.state.checkedLoginState = true;
        self.trigger(self.state);
      });
    },

    getFriendsList: function() {
      var self = this;
      FB.api("/me/friends",
        function (response)
        {
          if (response && !response.error) {
            self.state.friends = response.data;
            self.trigger(self.state);

            window.FBFriends = response.data;
            if (!window.FBID2Name) {
              window.FBID2Name = {};
            }
            for (var i = 0; i < response.data.length; i++) {
              var user = response.data[i];
              window.FBID2Name[user.id] = user.name;
            }

            var event = new CustomEvent("gotFriendsList");
            document.dispatchEvent(event);

            $.get('social/get_public_sharing_friends', {friends: response.data}, function (resp) {
              self.state.publicFriends = resp.friends;
              self.trigger(self.state);
            })
          }
        }
      );
    },

    acceptRequest: function(req) {
      var self = this;
      $.post('social/share_confirm', {sr_id:req.id}, function (data) {
        var index = self.state.requests.indexOf(req);
        self.state.requests = ReactUpdate(self.state.requests, {$splice: [[index, 1]]});
        self.state.shareUsers = data.shareUsers;
        self.trigger(self.state);
      });
    },

    sendRequest: function(friend) {
      var self = this;
      $.post("social/share_request", {a: this.state.fb_id, b: friend.id}, function (data) {
        self.state.requested = data.requested;
        self.trigger(self.state);
      });
    },

    unshare: function(friend_id) {
      var self = this;
      $.post("social/unshare", {nonfriend: friend_id}, function (data) {
        self.state.shareUsers = data.shareUsers;
        self.trigger(self.state);
      });
    }
  });
})();