// Generated by CoffeeScript 1.7.1

/*
Авторизация:
  1. Проверяем localStorage.oAuth, если есть, проверяем expires
  2. Если expires просрочен, то запрашиваем новый при помощи refresh_token
  3. Если refresh_token просрочен, запрашиваем новый при помощи логина и пароля
 */

(function() {
  angular.module("4treeApp").service('oAuth2Api', [
    '$q', '$http', '$rootScope', function($q, $http, $rootScope) {
      return {
        user_info: {
          client_id: '4tree_client',
          client_secret: '4tree_secret',
          username: 'imater',
          password: '990990'
        },
        jsCheckTokenExpired: function(oauth_saved) {
          var parsed;
          parsed = JSON.parse(oauth_saved);
          if (!parsed.expire_time) {
            console.info('token none');
            return false;
          }
          if (new Date(parsed.expire_time) <= new Date()) {
            console.info('token is expired');
            return parsed;
          } else {
            console.info('token is valid');
            return false;
          }
        },
        jsGetToken: function() {
          var dfd, mythis, oauth_saved, save_and_answer_token, token_data_saved, token_expired;
          dfd = $q.defer();
          mythis = this;
          save_and_answer_token = function(token_data) {
            token_data.expire_time = new Date(new Date().getTime() + token_data.expires_in * 1000);
            localStorage.setItem("oAuth20_" + mythis.user_info.username, JSON.stringify(token_data));
            return dfd.resolve(token_data.access_token);
          };
          oauth_saved = localStorage.getItem("oAuth20_" + this.user_info.username);
          if (!oauth_saved || (oauth_saved && (token_expired = this.jsCheckTokenExpired(oauth_saved)))) {
            if (token_expired) {
              this.jsGetRemoteTokenByRefreshToken(token_expired.refresh_token).then(save_and_answer_token);
            } else {
              this.jsGetRemoteTokenByPassword().then(save_and_answer_token);
            }
          } else {
            token_data_saved = JSON.parse(oauth_saved);
            dfd.resolve(token_data_saved.access_token);
          }
          return dfd.promise;
        },
        jsGetRemoteTokenByRefreshToken: function(refresh_token) {
          var dfd;
          dfd = $q.defer();
          console.info("REFRESH TOKEN = ", refresh_token);
          $http({
            url: $rootScope.$$childTail.set.server + '/oauth/token',
            method: "POST",
            isArray: true,
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded'
            },
            params: {},
            data: $.param({
              grant_type: 'refresh_token',
              client_id: this.user_info.client_id,
              client_secret: this.user_info.client_secret,
              refresh_token: refresh_token
            })
          }).then(function(result) {
            return dfd.resolve(result.data);
          });
          return dfd.promise;
        },
        jsGetRemoteTokenByPassword: function() {
          var dfd;
          dfd = $q.defer();
          $http({
            url: $rootScope.$$childTail.set.server + '/oauth/token',
            method: "POST",
            isArray: true,
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded'
            },
            params: {},
            data: $.param({
              grant_type: 'password',
              client_id: this.user_info.client_id,
              client_secret: this.user_info.client_secret,
              username: this.user_info.username,
              password: this.user_info.password
            })
          }).then(function(result) {
            return dfd.resolve(result.data);
          });
          return dfd.promise;
        }
      };
    }
  ]);

}).call(this);

//# sourceMappingURL=srv_oauth2api.map
