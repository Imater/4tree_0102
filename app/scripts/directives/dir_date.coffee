###
  Should be used as <odometer ng-model="myModel"></odometer>
###

'use strict'
angular.module('4treeApp').directive 'miniDate', [
  "calendarBox"
  (calendarBox) ->
    return (
      restrict: 'A'
      require: 'ngModel'
      scope:
        model: '=ngModel'
      link: ($scope, el, attr, ngModel) ->
        dateToTxt = (dat)->
          date = moment(dat);
          days = date.diff(moment(), 'days');
          if days < 1 and days > -2
            text = date.calendar();
          else
            text = date.format('l в HH:MM');
          #text += ' ('+date.fromNow()+')';
          { text }
        ngModel.$render = ->
          if ngModel.$viewValue.date1
            d1 = dateToTxt(ngModel.$viewValue.date1)
          else
            d1 = {text: ' ', class:'nodate'}
          d2 = dateToTxt(ngModel.$viewValue.date2) if ngModel.$viewValue.date2
          txt = '';
          txt += d1.text if d1?.text
          txt += ' — '+d2.text if d2?.text
          el.html( '<div class="date_txt">'+txt+'</div>' );



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