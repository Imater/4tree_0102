angular.module("4treeApp").service 'calendarBox', ['$translate', ($translate) ->
	constructor: (@$timeout) -> 
		@color = 'grey'
	getDate: (args) ->
		1
	getDates: (args) ->
		@getDate(args.today)
	getDateBox: (date) ->
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
]