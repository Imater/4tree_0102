###
Авторизация:
  1. Проверяем localStorage.oAuth, если есть, проверяем expires
  2. Если expires просрочен, то запрашиваем новый при помощи refresh_token
  3. Если refresh_token просрочен, запрашиваем новый при помощи логина и пароля
###


angular.module("4treeApp").service 'oAuth2Api', ['$q', '$http', '$rootScope', ($q, $http, $rootScope) ->
  user_info:
    client_id: '4tree_client'
    client_secret: '4tree_secret'
    username: 'eugene.leonar@gmail.com'
    password: '990990'
  jsCheckTokenExpired: (oauth_saved)->
    parsed = JSON.parse(oauth_saved);
    if !parsed.expire_time
      __log.warn 'token none'
      return false #токен не в порядке
    if( new Date(parsed.expire_time) <= new Date() )
      __log.warn 'token is expired'
      return parsed #токен просрочен
    else
      return false #токен валидный
  jsGetToken: ()->
    dfd = $q.defer();
    mythis = @;

    save_and_answer_token = (token_data)->
      token_data.expire_time = new Date(new Date().getTime() + token_data.expires_in * 1000);
      localStorage.setItem "oAuth20_" + mythis.user_info.username, JSON.stringify token_data
      dfd.resolve(token_data.access_token);

    oauth_saved = localStorage.getItem("oAuth20_" + @user_info.username)
    if !oauth_saved or ( oauth_saved and token_expired = @jsCheckTokenExpired(oauth_saved) )
      if(token_expired) #пытаемся получить новый токен при помощи Refresh_Token, чтобы не светить паролем
        __log.info 'Получаю token из localStorage ', token_expired
        @jsGetRemoteTokenByRefreshToken(token_expired.refresh_token).then save_and_answer_token
      else
        __log.info 'Получаю token из пароля', token_expired
        @jsGetRemoteTokenByPassword().then save_and_answer_token
    else
      token_data_saved = JSON.parse oauth_saved
      dfd.resolve(token_data_saved.access_token)

    dfd.promise;
  #запрашиваю токен в сети
  jsGetRemoteTokenByRefreshToken: (refresh_token)->
    dfd = $q.defer();

    __log.warn "REFRESH TOKEN = ", refresh_token
    console.info 'start'
    $http({
      url: $rootScope.$$childTail.set.server + '/api/v2/oauth/token'
      method: "POST"
      isArray: true
    #dataType: 'json'
      headers: {'Content-Type': 'application/x-www-form-urlencoded'}
      params:
        {
        #grant_type: 'password'
        }
      data: $.param {
        grant_type: 'refresh_token'
        client_id: @user_info.client_id
        client_secret: @user_info.client_secret
      #username: @user_info.username
      #password: @user_info.password
        refresh_token: refresh_token
      }
    }).then (result)->
      console.info {result}
      dfd.resolve(result.data);

    dfd.promise
  jsGetRemoteTokenByPassword: ()->
    dfd = $q.defer();

    h = $http({
      url: $rootScope.$$childTail.set.server + '/api/v2/oauth/token'
      method: "POST"
      isArray: true
    #dataType: 'json'
      headers: {'Content-Type': 'application/x-www-form-urlencoded'}
      params:
        {
        #grant_type: 'password'
        }
      data: $.param {
        grant_type: 'password'
        client_id: @user_info.client_id
        client_secret: @user_info.client_secret
        username: @user_info.username
        password: @user_info.password
      }
    }).error (d,err)->
      if err == 400
        document.location.hash = '#/login/';
    .then (result)->
      dfd.resolve(result.data);


    dfd.promise;
]