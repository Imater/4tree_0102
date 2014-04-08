angular.module("4treeApp").service 'calendarBox', ['$translate', 'db_tree', '$rootScope', ($translate, db_tree, $rootScope) ->
  _calendar_container: [1..5000]
  datasource: ()->
    [1..5000]
  constructor: (@$timeout) -> 
    @color = 'grey'
  getDate: (args) ->
    1
  jsDateDiff: (date2, only_days) ->
    answer =
      text: "∞"
      class: "nodate"
      image: ""

    return answer unless date2
    return answer if date2 is "0000-00-00 00:00:00"

    answer.class = "";
    now = new Date;
    if(only_days)
      now.setHours(0);
      now.setMinutes(0);
      now.setSeconds(0);
      date2 = new Date( date2 );
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
        answer.text = ((if (minutes > 0) then "+ " else "")) + hours + " ч."
      else
        answer.text = ((if (minutes > 0) then "+ " else "")) + minutes + " мин."
      if (only_days)
        answer.text = "сегодня";
    else
      answer.text = ((if (days > 0) then "+ " else "")) + days + " дн."
    if (days is 0)
      if minutes < 0
        answer.class = "datetoday past"
        pr2 = (-minutes / 480) * 100
        pr2 = 80 if pr2 > 80
        answer.image = "background-image: -webkit-gradient(linear, left top, right top, color-stop(" + (pr2 - 25) + "%, #f56571), color-stop(" + (pr2 + 25) + "%, rgba(0,0,0,0))) !important;"
      
      #"-webkit-gradient(linear, right top, left top, color-stop("+pr+", #da5700), color-stop("+(pr+0.1)+", #990000));";
      #"-webkit-gradient(linear, 50% 0%, 50% 100%, color-stop(0%, #333), color-stop(100%, #222))"
      answer.class = "datetoday"  if minutes >= 0
    else answer.class = "datepast"  if minutes < 0
    answer
  getDates: (args) ->
    @getDate(args.today)
  getDateBox: _.memoize (date) ->
    @current_month = (new Date()).getMonth() if (!@current_month);
    day = date.getDate().toString();
    month1 = date.getMonth();
    year = date.getFullYear().toString().substr(2,4);
    fulldate = date;
    week_day = $translate( 'WEEKDAY.'+(date.getDay() ) )
    month = $translate( 'MONTH.'+(month1+1 ) )
    myclass = 'week_'+(date.getDay());
    myclass += " past" if date < new Date()
    myclass += " today" if date.toString() == new Date().toString()
    add = 1 if (@current_month%2)
    #myclass += " odd_month" if ((month1 + add)%2) 
    #myclass += " this_month" if month1 == @current_month;
    answer = {day, month, year, week_day, myclass, fulldate}
  getDays: 
    _.memoize (date, only_days)->
      @jsDateDiff(date, only_days)
    , (date, only_days) -> 
      (date + parseInt( new Date().getTime()/1000/120 ) + only_days )
  getCalendarForIndex: ($index)->
    $index = $index + $rootScope.$$childHead.set.from_today_index
    date = new Date( new Date().getTime() + ($index-3)*24*60*60*1000 );
    element = @getDateBox(date);
    key = moment(element.fulldate).format('YYYY-MM-DD');
    element.tasks = db_tree.getView('tasks', 'tasks_by_date').result[key]
    _.each element.tasks, (task)->
      tm = moment(task.date2).format('HH:MM')
      task.time = tm;
    element.tasks = _.sortBy element.tasks, (task)->
      task.time;
    element
  getToDoForIndex: ($date)->
    date = new Date($rootScope.$$childHead.set.today_date);
    element = {};
    key = moment(date).format('YYYY-MM-DD');
    element.tasks = db_tree.getView('tasks', 'tasks_by_date').result[key]
    _.each element.tasks, (task)->
      tm = moment(task.date2).format('HH:MM')
      task.time = tm;
    element.tasks = _.sortBy element.tasks, (task)->
      task.time;
    element

  #, ($index) ->
  #  $rootScope.$$childHead.set.from_today_index+$index
]

















