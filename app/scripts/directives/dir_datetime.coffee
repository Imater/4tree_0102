
angular.module("4treeApp").directive "dateTimeInput", ($timeout, $compile)->
  restrict: "E"
  require: "?ngModel"
  scope: {

  }
  template: ()->

    return ' <div class="datetimeinput">'+
                '<div class="dt_wrap">'+
                  '<i class="icon-up-dir"></i>'+
                  '<input class="day" size="2" only-digits>'+
                  '<i class="icon-down-dir"></i>'+
                '</div>'+

                '<div class="dt_wrap">'+
                  '<i class="icon-up-dir"></i>'+
                  '<input class="month" size="5">'+
                  '<i class="icon-down-dir"></i>'+
                '</div>'+

                '<div class="dt_wrap">'+
                  '<i class="icon-up-dir"></i>'+
                  '<input class="year" size="4">'+
                  '<i class="icon-down-dir"></i>'+
                '</div>'+

                '<div class="dt_wrap">'+
                '<i class="icon-up-dir"></i>'+
                '<input class="hours" size="2">'+
                '<i class="icon-down-dir"></i>'+
                '</div>'+

                '<div class="dt_wrap">'+
                '<i class="icon-up-dir"></i>'+
                '<input class="minutes" size="2">'+
                '<i class="icon-down-dir"></i>'+
                '</div>'+

    '</div>'
  link: (scope, el, attr, ngModel) ->

    params = {
      key_code: {
        up: 38
        down: 40
      }
      month_names: [
        'января'
        'февраля'
        'марта'
        'апреля'
        'мая'
        'июня'
        'июля'
        'августа'
        'сентября'
        'октября'
        'ноября'
        'декабря'
      ]
      keys: [
        8
        9
        19
        20
        27
        33
        34
        35
        36
        37
        38
        39
        40
        45
        46
        144
        145
      ]
    }


    renderDate = (el, viewValue)->
      date = new Date(viewValue)
      el.find('.day').val date.getDate() or ""
      el.find('.month').val params.month_names[ date.getMonth() ] or ""
      el.find('.year').val date.getFullYear() or ""
      el.find('.hours').val date.getHours() or ""
      el.find('.minutes').val date.getMinutes() or ""

    ngModel.$render = ->
      renderDate(el, ngModel.$modelValue)

    scope.$watch ()->
      ngModel.$modelValue
    , ()->
      renderDate(el, ngModel.$modelValue)

    parseDateFromInput = (el)->
      day = el.find('.day').val();
      month = el.find('.month').val();
      year = el.find('.year').val();
      hours = el.find('.hours').val();
      minutes = el.find('.minutes').val();
      day = parseInt(day);
      hours = parseInt(hours);
      minutes = parseInt(minutes);
      substr_month = month.substr(0,4);
      found_month_key = new Date().getMonth();
      month = _.find params.month_names, (month, key)->
        found_month_key = key if substr_month.indexOf(month.substr(0,4))!=-1
      year = parseInt(year);


      new Date( year, found_month_key, day, hours, minutes )

    el.on 'keyup', 'input', (e)->
      if e.which == 13
        angular.element('.month').focus();        

    el.on 'blur', 'input', (e)->
      parsed_date = parseDateFromInput(el);
      if _.isDate(parsed_date)
        scope.$apply ()->
          ngModel.$setViewValue new Date(parsed_date)

    charLimit = 2
    el.on 'keyup', '.day', (e) ->
      if e.which is 8 and @value.length is 0
        #$(this).prev(".inputs").focus()
      else if $.inArray(e.which, params.keys) >= 0
        true
      else if @value.length >= charLimit and @value <= 31 and !e.shiftKey and e.which != 16 and e.which != 9
        angular.element('.month').focus();
        $timeout ()->
          angular.element('.month').select();
        false
      else false  if e.shiftKey or e.which <= 48 or e.which >= 58
      return

    el.on 'keydown', 'input', (e)->
      if e.keyCode == params.key_code.up
        e.preventDefault();
        e.stopPropagation();
        date = ngModel.$modelValue;
        if $(this).hasClass('day')
          dt = new Date(date).getTime()
          scope.$apply ()->
            ngModel.$setViewValue new Date(dt + 24*60*60*1000)
        if $(this).hasClass('month')
          dt = new Date(date);
          scope.$apply ()->
            ngModel.$setViewValue new Date( dt.setMonth( dt.getMonth() + 1 ) );
        if $(this).hasClass('year')
          dt = new Date(date);
          scope.$apply ()->
            ngModel.$setViewValue new Date( dt.setFullYear( dt.getFullYear() + 1 ) );
        if $(this).hasClass('hours')
          dt = new Date(date);
          scope.$apply ()->
            ngModel.$setViewValue new Date( dt.setHours( dt.getHours() + 1 ) );
        if $(this).hasClass('minutes')
          dt = new Date(date);
          scope.$apply ()->
            ngModel.$setViewValue new Date( dt.setMinutes( dt.getMinutes() + 1 ) );
      if e.keyCode == params.key_code.down
        e.preventDefault();
        e.stopPropagation();
        date = ngModel.$modelValue;
        if $(this).hasClass('day')
          dt = new Date(date).getTime()
          scope.$apply ()->
            ngModel.$setViewValue new Date(dt - 24*60*60*1000)
        if $(this).hasClass('month')
          dt = new Date(date);
          scope.$apply ()->
            ngModel.$setViewValue new Date( dt.setMonth( dt.getMonth() - 1 ) );
        if $(this).hasClass('year')
          dt = new Date(date);
          scope.$apply ()->
            ngModel.$setViewValue new Date( dt.setFullYear( dt.getFullYear() - 1 ) );
        if $(this).hasClass('hours')
          dt = new Date(date);
          scope.$apply ()->
            ngModel.$setViewValue new Date( dt.setHours( dt.getHours() - 1 ) );
        if $(this).hasClass('minutes')
          dt = new Date(date);
          scope.$apply ()->
            ngModel.$setViewValue new Date( dt.setMinutes( dt.getMinutes() - 1 ) );











