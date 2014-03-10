angular.module("4treeApp").service 'calendarBox', ['$translate', ($translate) ->
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
	      answer.image = "background-image: -webkit-gradient(linear, left top, right top, color-stop(" + pr2 + "%, #fcbec2), color-stop(" + (pr2 + 10) + "%, #feaa0c));"
	    
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
		week_day = $translate( 'WEEKDAY.'+(date.getDay() ) )
		month = $translate( 'MONTH.'+(month1+1 ) )
		myclass = 'week_'+(date.getDay());
		myclass = "today" if date.toString() == new Date().toString()
		add = 1 if (@current_month%2)
		myclass += " odd_month" if ((month1 + add)%2) 
		myclass += " this_month" if month1 == @current_month;
		answer = {day: day, month: month, week_day: week_day, myclass: myclass}
	getDays: 
		_.memoize (date, only_days)->
			@jsDateDiff(date, only_days)
		, (date, only_days) -> 
			(date + parseInt( new Date().getTime()/1000/120 ) + only_days )
]