angular.module("4treeApp").service 'calendarBox', ['$translate', 'db_tree', '$rootScope',
  ($translate, db_tree, $rootScope) ->
    _calendar_container: [1..5000]
    datasource: ()->
      [1..5000]
    constructor: (@$timeout) ->
      @color = 'grey'
    getDate: (args) ->
      1
    jsDateDiff: (date2, only_days) ->
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
    getDates: (args) ->
      @getDate(args.today)
    getDateBox: _.memoize (date) ->
      @current_month = (new Date()).getMonth() if (!@current_month)
      day = date.getDate().toString();
      month1 = date.getMonth();
      year = date.getFullYear().toString().substr(2, 4);
      fulldate = date;
      week_day = $translate('WEEKDAY.' + (date.getDay() ))
      month = $translate('MONTH.' + (month1 + 1 ))
      myclass = 'week_' + (date.getDay());
      myclass += " past" if date < new Date()
      myclass += " today" if date.toString() == new Date().toString()
      add = 1 if (@current_month % 2)
      #myclass += " odd_month" if ((month1 + add)%2)
      #myclass += " this_month" if month1 == @current_month;
      answer = {day, month, year, week_day, myclass, fulldate}
    getDays: _.memoize (date, only_days)->
      @jsDateDiff(date, only_days)
    , (date, only_days)->
      date+only_days
    getCalendarForIndex: ($index)->
      $index = $index + $rootScope.$$childHead.set.from_today_index
      date = new Date(new Date().getTime() + ($index - 3) * 24 * 60 * 60 * 1000);
      element = @getDateBox(date);
      key = moment(element.fulldate).format('YYYY-MM-DD');
      element.tasks = db_tree.getView('tasks', 'tasks_by_date').result[key]
      _.each element.tasks, (task)->
        tm = moment(task.date2).format('HH:MM')
        task._time = tm;
      element.tasks = _.sortBy element.tasks, (task)->
        task._time;
      element
    getToDoForIndex: ($date)->
      date = new Date($date);
      element = {};
      key = moment(date).format('YYYY-MM-DD');
      element.tasks = db_tree.getView('tasks', 'tasks_by_date').result[key]
      _.each element.tasks, (task)->
        tm = moment(task.date2).format('HH:MM')
        task._time = tm;
      element.tasks = _.sortBy element.tasks, (task)->
        task._time;
      element

    #, ($index) ->
    #  $rootScope.$$childHead.set.from_today_index+$index
    getDateOfWeek: (w, y)->
      d = (1 + (w - 1) * 7); # 1st of January + 7 days for each week
      return new Date(y, 0, d);
    getDateOfISOWeek: (w, y) ->
      simple = new Date(y, 0, 1 + (w - 1) * 7)
      dow = simple.getDay()
      ISOweekStart = simple
      if dow <= 4
        ISOweekStart.setDate simple.getDate() - simple.getDay() + 1
      else
        ISOweekStart.setDate simple.getDate() + 8 - simple.getDay()
      ISOweekStart
    getWeek: (date)->
      onejan = new Date(date.getFullYear(), 0, 1);
      return Math.ceil((((date - onejan) / 86400000) + onejan.getDay() + 1) / 7);
    getWeekByMonth: (month_number)->
      date = new Date();
      this_week = @getWeek(date);
      date.setMonth(month_number - 1);
      @getWeek(date) - this_week - 4
    getWeekByYear: (month_number)->
      date = new Date();
      this_week = @getWeek(date);
      date.setYear(month_number);
      @getWeek(date) - this_week - 4
    getWeekCalendarForIndex: _.memoize ($index)->
      mythis = @;
      today = new Date();
      first_day_of_month = new Date(today.getFullYear(), today.getMonth(), 0);
      this_week = mythis.getWeek(new Date(first_day_of_month));
      week = [
        {},
        {},
        {},
        {},
        {},
        {}
      ]
      convertGetDay = [6, 0, 1, 2, 3, 4, 5]
      date = mythis.getDateOfISOWeek($index + this_week - 2, today.getFullYear());
      _.each [1..7], (week_day)->
        tasks = mythis.getToDoForIndex(date);
        myclass = if ( (date.getMonth() + (if today.getMonth() % 2 then 1 else 0) ) % 2 ) then 'odd' else 'even';
        myclass = myclass + ' today' if moment(date).format('YYYY-MM-DD') == moment(today).format('YYYY-MM-DD');
        week_index = convertGetDay[date.getDay()];
        myclass = myclass + (if week_index >= 5 then ' weekend' else '')
        date_title = date.getDate();
        if (date.getDate() == 1)
          date_title += ' ' + $translate('MONTH.' + (date.getMonth() + 1 ))
        week[ week_index ] = ( {date: date_title, tasks: tasks, myclass: myclass} )
        date = new Date(date.getTime() + 24 * 60 * 60 * 1000);
        return
      week
]


angular.module("4treeApp").controller "WeekCalendarController", [ '$scope', 'calendarBox', 'db_tree', '$translate',
  ($scope, calendarBox, db_tree, $translate) ->
    $scope.$on 'position.first', (e, first, next, bufferSize)->
      first_date = calendarBox.getDateOfISOWeek(next + bufferSize - 4, new Date().getFullYear());
      month_number = first_date.getMonth() + 1;
      $scope.this_month = $translate('MONTH_FULL.' + ( month_number ))
      $scope.this_year = first_date.getFullYear();
      $scope.isWeek = true;
      $scope.monthes = [
        {title: 'Январь!', goto: calendarBox.getWeekByMonth(1) }
        {title: 'Февраль', goto: calendarBox.getWeekByMonth(2)}
        {title: 'Март', goto: calendarBox.getWeekByMonth(3)}
        {title: 'Апрель', goto: calendarBox.getWeekByMonth(4)}
        {title: 'Май', goto: calendarBox.getWeekByMonth(5)}
        {title: 'Июнь', goto: calendarBox.getWeekByMonth(6)}
        {title: 'Июль', goto: calendarBox.getWeekByMonth(7)}
        {title: 'Август', goto: calendarBox.getWeekByMonth(8)}
        {title: 'Сентябрь', goto: calendarBox.getWeekByMonth(9)}
        {title: 'Октябрь', goto: calendarBox.getWeekByMonth(10)}
        {title: 'Ноябрь', goto: calendarBox.getWeekByMonth(11)}
        {title: 'Декабрь', goto: calendarBox.getWeekByMonth(12)}
      ]
      $scope.goTo = (index)->
        $scope.$$childHead.$emit('goto_index', index + 1);
]

angular.module("4treeApp").controller "bigCalendarController", [ '$scope', 'calendarBox', 'db_tree', '$translate',
  ($scope, calendarBox, db_tree, $translate) ->
    $scope.$on 'position.first', (e, first, next, bufferSize)->
      first_date = new Date(new Date().getTime() + (first + bufferSize + 1) * 24 * 60 * 60 * 1000);
      month_number = first_date.getMonth() + 1;
      $scope.this_month = $translate('MONTH_FULL.' + ( month_number ));
      $scope.this_year = first_date.getFullYear();
      $scope.monthes = [
        {title: 'Январь', goto: 0}
        {title: 'Февраль', goto: 0}
        {title: 'Март', goto: 0}
        {title: 'Апрель', goto: 0}
        {title: 'Май', goto: 0}
        {title: 'Июнь', goto: 0}
        {title: 'Июль', goto: 0}
        {title: 'Август', goto: 0}
        {title: 'Сентябрь', goto: 0}
        {title: 'Октябрь', goto: 0}
        {title: 'Ноябрь', goto: 0}
        {title: 'Декабрь', goto: 0}
      ]
      $scope.goTo = (index)->
        $scope.$$childHead.$emit('goto_index', index - 8);
]












