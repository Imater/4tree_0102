angular.module("4treeApp").controller "LoginCtrl", [
  '$translate'
  '$scope'
  '$q'
  '$timeout'
  '$rootScope'
  'oAuth2Api'
  'cryptApi'
  'settingsApi'
  ($translate,
   $scope,
   $q,
   $timeout,
   $rootScope,
   oAuth2Api,
   cryptApi,
   settingsApi) ->
    $scope.tab = 'login'
    $scope.pass_type = "password"
    $scope.pass_placeholder = 'пароль'
    $scope.$watch 'show_password', (new_val, old_val)->
      if old_val != new_val
        if $scope.show_password
          $scope.pass_type = 'text';
          $scope.pass_placeholder = 'пароль виден'
        else
          $scope.pass_type = 'password';
          $scope.pass_placeholder = 'пароль'
        checkPass(new_val, old_val)

    $scope.$watch 'tab', (new_val, old_val)->
      checkPass(new_val, old_val)
      if $scope.email?.length
        $('input:eq(1)').focus();
      else
        $('input:first').focus();
    myemail = settingsApi.set.user_info.username;
    if myemail
      $scope.email = cryptApi.decrypt(myemail).text

    $scope.$watch 'email', (new_val, old_val)->
      if old_val != new_val
        checkPass(new_val, old_val)
        encrypted_email = cryptApi.encrypt new_val, 4
        settingsApi.set.user_info.username = encrypted_email;
        console.info encrypted_email;

    checkPass = (new_val, old_val)->
      if new_val != old_val
        if ( ($scope.tab == 'login' or $scope.show_password) and $scope.email?.length and ($scope.pas1?.length>2)) or
           ( !$scope.show_password and $scope.email?.length and ($scope.pas1?.length>2 and $scope.pas1 == $scope.pas2))
          $scope.all_ok = true;
        else
          $scope.all_ok = false;
    $scope.$watch 'pas1', checkPass
    $scope.$watch 'pas2', checkPass

    $scope.loginOrReg = ()->
      if $scope.tab == 'login'
        settingsApi.set.user_info.username = $scope.email
        settingsApi.set.user_info.password = $scope.pas1
        $rootScope.$emit('save_settings');
        oAuth2Api.jsGetRemoteTokenByPassword().then ()->
          oAuth2Api.jsGetToken().then ()->
            document.location.hash = '#/home'

]