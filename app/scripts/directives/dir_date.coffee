###
  Should be used as <odometer ng-model="myModel"></odometer>
###

'use strict'
angular.module('4treeApp').directive 'miniDate', [
  "$rootScope"
  "settingsApi"
  ($rootScope, settingsApi) ->
    jsMakeGradient = (pr2, red_color)->
      "background-image: -webkit-gradient(linear, left top, right top, color-stop("+
      (pr2 - 0) + "%, "+red_color+"), color-stop("+
      (pr2 + 0) + "%, rgba(0,0,0,0)));";
    jsDateDiff = (date2, only_days) ->
      answer =
        text: ""
        class: "nodate"
        image: ""

      return answer unless date2
      return answer if date2 is "0000-00-00 00:00:00"

      date2 = new Date(date2);

      answer.class = "";
      now = new Date;
      if(only_days)
        now.setHours(0);
        now.setMinutes(0);
        now.setSeconds(0);
        date2 = new Date(date2);
        date2.setHours(0);
        date2.setMinutes(0);
        date2.setSeconds(0);


      dif_sec = date2.getTime() - now
      dif_sec += 1000 if dif_sec > 0;
      dif_sec -= 1000 if dif_sec < 0;

      days = parseInt(dif_sec / (60 * 1000 * 60 * 24), 10)
      minutes = parseInt(dif_sec / (60 * 1000), 10)
      minutes = 0 if only_days and days == 0
      if days is 0
        if (minutes > 59) or (minutes < -59)
          hours = parseInt(dif_sec / (60 * 1000 * 60) * 10, 10) / 10
          answer.text = ((if (minutes > 0) then "+" else "")) + hours + " ч."
        else
          answer.text = ((if (minutes > 0) then "+" else "")) + minutes + " м."
        if (only_days)
          answer.text = "сегодня";
      else
        answer.text = ((if (days > 0) then "+" else "")) + days + " дн."
      if (days is 0)
        if minutes < 0
          answer.class = "datetoday past"
          pr2 = (-minutes / 480) * 100
          pr2 = 80 if pr2 > 80
          red_color = '#d7d7d7';
          if !date2.did
            answer.image = "background-image: -webkit-gradient(linear, left top, right top, color-stop(" + (pr2 - 25) + "%, "+red_color+"), color-stop(" + (pr2 + 25) + "%, rgba(0,0,0,0)));"

        #"-webkit-gradient(linear, right top, left top, color-stop("+pr+", #da5700), color-stop("+(pr+0.1)+", #990000));";
        #"-webkit-gradient(linear, 50% 0%, 50% 100%, color-stop(0%, #333), color-stop(100%, #222))"
        answer.class = "datetoday"  if minutes >= 0
      else answer.class = "datepast"  if minutes < 0
      answer
    return (
      restrict: 'A'
      require: 'ngModel'
      scope:
        model: '=ngModel'
      link: ($scope, el, attr, ngModel) ->

        $scope.$watch ()->
          step = Math.round( (settingsApi.tmp.tick_today_date_time)/(1000*30) )
          return step + ngModel.$modelValue.date1 +
                 ngModel.$modelValue.date2 +
                 ngModel.$modelValue.did
        , (newVal, oldVal)->
          if newVal != oldVal
            updateDate();


        updateDate = ->
          if ngModel.$viewValue.date1
            d1 = jsDateDiff(ngModel.$viewValue.date1)
          else
            d1 = {text: ' ', class:'nodate'}
          d2 = jsDateDiff(ngModel.$viewValue.date2) if ngModel.$viewValue.date2
          txt = '<div class="myprogress"></div>';
          txt += '<div class="txt"></div><span  class="date1">'+d1.text+'</span>' if d1?.text
          txt += '<span class="date2">'+d2.text+'</span></div>' if d2?.text
          txt += '';
          dt1 = new Date(ngModel.$viewValue.date1).getTime();
          dt2 = new Date(ngModel.$viewValue.date2).getTime();
          dt = settingsApi.tmp.tick_today_date_time;

          el.html( txt );
          progress = el.find('.myprogress');
          red = '';
          if dt>=dt1 and dt<=dt2
            pr2 = (100/(dt2-dt1))*(dt-dt1) ;
            progress.removeClass('red');
          else if dt >= dt2
            pr2 = (100/(dt2-dt1))*(dt-dt2) ;
            pr2 = 100 if pr2>100;
            progress.width(pr2+'%');
            red = 'red'
            progress.addClass('red');
          if !dt1 and !dt2
            red = 'nodate';
          if ngModel.$viewValue.did
            red = 'did';
            pr2 = 0;
          progress.width(pr2+'%');
          el.attr('class', 'task_date '+red)

        ngModel.$render = updateDate


    )
]

###

  -3дн — +12дн

  [-3дн] — [+12дн]

  [-3дн] [+12дн]

  [-3дн] 15 дней [+12дн]

  нач.3дн назад, кон.+12дн

  [ +12дн ] 14дн

  [-3дн] — [+12дн]

  начало сегодня в 18:00 — Помыть горшок
  до 18 мая ()

  с 12 до 18 мая

  -3 дн назад — Помыть машину
  +23 дн



###