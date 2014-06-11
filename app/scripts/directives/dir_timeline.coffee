angular.module("4treeApp").directive "timeLine", ->
  #templateUrl: 'views/subviews/time_line.html'
  #transclude: true
  restrict: "E"
  scope: {
    date1: '='
    date2: '='
    zoom: '='
    title: '='
    starttime: '='
  }
  require: "?ngModel"
  link: (scope, el, attrs, ngModel) ->


    timeline = {
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
      fora: 0*24*60*60*1000
      start_of_day: (now)->
        now_day = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
      timeToProcent: (time)->
        now = new Date();
        answer = 100*(time - scope.starttime)/(scope.zoom * 24 * 60 * 60 * 1000)
        answer
      pixelToTime: (pixel)->
        now = new Date().getTime();
        width = el.find('.timeline').width();
        answer = parseInt( scope.starttime + pixel * ( (scope.zoom*24*60*60*1000) / width ) )
      pixelToTime2: (pixel)->
        now = new Date().getTime();
        width = el.find('.timeline').width();
        answer = parseInt( now + pixel * ( (scope.zoom*24*60*60*1000) / width ) )

      drawTimeLine: ()->
        table = '<div class="timeline noselectable">'+
          '<div class="absolutes">'+
          '<div class="table_wrap">';
        i = -1;
        now = new Date().getTime();
        today_format = moment(now).format("DD/MM/YYYY");
        while (i++) < (scope.zoom)
          today = @start_of_day( new Date( scope.starttime + (i)*24*60*60*1000 ) );
          week_day = new Date(today).getDay();
          dayclass="";
          dayclass+=" weekend" if week_day == 0 or week_day == 6
          today_td = moment(today).format("DD/MM/YYYY");
          label_left = timeline.timeToProcent(today);
          label_width = 100/scope.zoom;
          table += '<div '+
                   'data-date="'+today_td+'"'+
                   ' style="left:'+ label_left + '%; width:'+label_width+'%"' +
                   ' class="label '+dayclass+'">'+
                   (moment(today).format('DD'))+
                   '</div>';

        table += '</div><div class="today_line"></div>'+
          '<div class="line"></div>'+
          '<div class="event"><div class="title"></div><div class="event_line"><div class="d1"><b></b><i></i></div>'+
          ''+
          '<div class="d2"><b></b><i></i></div></div></div>'+
          '</div>';
        return table
      drawEvent: (d1, d2) ->
        d1 = new Date( d1 ).getTime();
        d2 = new Date( d2 ).getTime();
        now = new Date().getTime();
        d1_diff = timeline.jsDateDiff( new Date( d1 ) );
        d2_diff = timeline.jsDateDiff( new Date( d2 ) );
        tm1 = moment(d1).format('H:mm');
        tm2 = moment(d2).format('H:mm');
        el.find('.d1').attr('title', moment(d1).format("DD/MM/YYYY H:mm") ).find('b').html( d1_diff.text );
        di1 = el.find('.d1').find('i').html(tm1);
        el.find('.d2').attr('title', moment(d2).format("DD/MM/YYYY H:mm") ).find('b').html( d2_diff.text );
        di2 = el.find('.d2').find('i').html(tm2);
        el.find('.title').html(scope.title);
        if Math.abs(d1 - now) < 2*24*60*60*1000
          di1.addClass('soon');
        if Math.abs(d2 - now) < 2*24*60*60*1000
          di2.addClass('soon');
        left_today = @timeToProcent( now );
        el.find('.today_line').css({'left': left_today+'%'})
        left = @timeToProcent(d1);
        right = @timeToProcent(d2);
        width = right-left;
        el.find('.event').css({'left':left+'%', width: width+'%'});
    }

    d1 = null;
    d2 = null;
    d_width = null;
    width = null;
    move_element = null;
    d1_delta = null;
    starttime_store = null;

    bindKeys = ()->
      el.find('.d2,.d1,.event,.table_wrap').on 'mousedown', (e)->
        if e.which == 1
          e.stopPropagation();
          d1 = new Date( scope.date1 );
          d2 = new Date( scope.date2 );
          offset = el.find('.timeline').offset();
          startX = offset.left;
          startY = offset.top;
          move_element = $(this).attr('class');
          if move_element == 'event'
            d1_start = timeline.pixelToTime( e.clientX-startX );
            d1_delta = parseInt( d1_start - d1.getTime() );
            d_width = d2.getTime() - d1.getTime();
          if move_element == 'table_wrap'
            starttime_store = scope.starttime;
            store_zoom = scope.zoom;
            d1_delta = e.clientX-startX;
          $('html').addClass('noselectable');
          width = el.find('.timeline').width();
          $(window).on 'mouseup.myup', (e, t)->
            $('html').removeClass('noselectable');
            console.info 'off';
            $(window).off('mousemove.mymove').off('mouseup.myup')
            scope.date1 = new Date( d1 );
            scope.date2 = new Date( d2 );

          bounceDraw = _.throttle (d1, d2)->
            timeline.drawEvent(d1, d2);
          , 10

          $(window).on 'mousemove.mymove', (e, t)->
            x = e.clientX - startX
            y = e.clientY - startY
            #console.info 'y = ',y, move_element
            x = x + y*0.1;
            if move_element == 'd1'
              d1 = new Date( timeline.pixelToTime( x ) );
            if move_element == 'd2'
              d2 = new Date( timeline.pixelToTime( x ) );
            if move_element == 'event'
              d1 = new Date(new Date( timeline.pixelToTime( x ) ).getTime() - d1_delta);
              d2 = new Date( d1.getTime()+d_width )
            if move_element == 'table_wrap'
              scope.$apply ()->
                if Math.abs(y) < 50
                  width = el.find('.timeline').width();
                  answer = parseInt( (x-d1_delta) * ( (scope.zoom*24*60*60*1000) / width ) )
                  scope.starttime = starttime_store - answer;
                else
                  scope.zoom = store_zoom + y / 20;


            bounceDraw(d1, d2);

    timeline.line_start_date = parseInt(scope.zoom * 0.5);

    el.html( timeline.drawTimeLine(scope.zoom) );
    bindKeys();

    timeline.drawEvent(scope.date1, scope.date2);

    scope.$watch 'date1+date2+title', (new_val, old_val)->
      if new_val != old_val
        timeline.drawEvent(scope.date1, scope.date2);

    scope.$watch 'starttime+zoom', (new_val, old_val)->
      if new_val != old_val
        el.html( timeline.drawTimeLine(scope.zoom) );
        bindKeys();
        timeline.drawEvent(scope.date1, scope.date2);

    console.info ' s = ', scope.starttime





