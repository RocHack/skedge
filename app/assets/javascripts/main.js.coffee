# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

style = (day,start,duration,color) -> 
	width = 100.0/days.length
	hour = 100/(max-min + 1)
	height = duration * hour
	left = days.indexOf(day.toUpperCase())*width
	top = hour*start
	{
		"width":"#{width}%",
		"left":"#{left}%",
		"top":"#{top}%",
		"height":"#{height}%",
		"display":"block",
		"background-color":color
	}

exists_conflict = (c1, c2) ->
	day_overlap = null
	if c1.days && c2.days
		day_overlap = c1.days.split("").map( (day) ->
			c2.days.indexOf(day) > -1
		).reduce ((a, b) -> a || b)
	if !day_overlap
		return false
	
	((c1.start_time >= c2.start_time && c1.start_time < c2.end_time) || 
	(c1.end_time > c2.start_time && c1.end_time <= c2.end_time))

MAIN = 0
LAB = 1
REC = 2
LL = 3 
WRK = 4

type2name = (type, short, ignore_section) ->
	switch type
		when MAIN
			if ignore_section then "" else "Section"
		when LAB
			"Lab"
		when REC
			if short then "REC" else "Recitation"
		when LL
			if short then "L/L" else "Lab Lecture"
		when WRK
			if short then "WRK" else "Workshop"
		else
			""

days = ["M", "T", "W", "R", "F"]
color = 0
colors = ["#FF7620", "#139CD3", "#1BCF11", "#672357", "#074098", "#6E53B5"]
courses = []

s_id = null
s_rid = null
secret = null

min = 0
max = 0

root = exports ? this

hour_range = (extra) ->
	extra = [] if !extra

	min = 2500
	max = -1

	for c in courses.concat(extra)
		start = c.start_time-5
		end = c.end_time+5
		if start < min
			min = start
		if end > max
			max = end
		s = (c.days.indexOf('S') > -1)
		u = (c.days.indexOf('U') > -1)
		
	min /= 100
	max /= 100

	diff = max-min
	min_hrs = 7
	if (diff < min_hrs)
		min -= (min_hrs-diff)/2
		max += (min_hrs-diff)/2

	min = Math.floor(min)
	max = Math.ceil(max)
	[min..max]

root.resize_days = (extra) ->
	$('#days').html("")
	s = false
	u = false

	days = ["M", "T", "W", "R", "F"]

	extra = [] if !extra

	for c in courses.concat(extra)
		s = true if c.days.indexOf('S') > -1
		u = true if c.days.indexOf('U') > -1

	if s
		days.push("S")
	if u
		days = ["U"].concat(days)

	for d in days
		$('#days').append("<th>#{d}</th>")

	$('th').css('width',"#{100.0/days.length}%")

	if days.length > 5
		$('.s-block-time').hide()


root.resize_schedule = (extra) ->
	resize_days(extra)

	$('#hour-rows').html("")
	for i in hour_range(extra)
		$('#hour-row').clone().css('display','table-row').appendTo($('#hour-rows')).find('.time').html((i-1) % 12 + 1)

	full = $('.wrapper').hasClass('s-big')

	s = courses
	courses = []
	for c in s
		$(".b-#{c.crn}").remove()
		add_course(c, full)

	if full
		$('.s-full').height(Math.max((max-min)*67, 750))

cookie = document.cookie
if cookie
	match = cookie.match(/s_id=(\d+)&(.*?)(;| |$)/)
	if match
		s_id = match[1]
		secret = match[2]

set_cookie = ->
	expdate = new Date()
	expdate.setTime(expdate.getTime() + (1000 * 24 * 60 * 60 * 365 * 4)) #4 yrs lol
	document.cookie = "s_id=#{s_id}&#{secret}; expires=#{expdate.toUTCString()};"

add_block = (obj) ->
	blx = []
	if !obj.color
		obj.color = colors[color++ % colors.length]

	for day in obj.days.split("")
		s = style(day,obj.time_in_hours-min,obj.duration,obj.color)
		c = $("#template").clone().addClass("b-#{obj.crn}").css(s).appendTo($('.courses'))
		c.find('.s-block-dept').html(obj.dept)
		c.find('.s-block-cnum').html(obj.num)
		c.find('.s-block-time').html(obj.time)
		c.find('.s-block-title').html(obj.name)
		c.find('.s-block-type').html(type2name(obj.course_type, true, true))
		blx.push(c)

	$(".b-#{obj.crn}")

ajax = (route, obj_id, success, fail) -> 
	$.post("schedule/#{if s_id then s_id else "new"}/#{route}", {"obj_id":obj_id, "secret":secret}, (data) ->
		is_new = !s_id
		if is_new
			s_id = data.id
			s_rid = data.rid
			secret = data.secret
			set_cookie()
		success(is_new)
	).fail ->
		fail()
		alert("an error occurred - pls check your internet connection?")

course_ajax = (obj, action) ->
	ajax(action, obj.crn, 
		((is_new) -> 
			$('#share-link').attr("href","#{s_rid}")
			$('#share-link').show()
			$('.download').show()
			$('#download-img').attr("href","#{s_rid}#img")),
		( ->
			remove_section_obj(obj, true)
			compute_buttons()))

root.add_course = (obj, popover, post, col) ->
	if col
		obj.color = col
	c = add_block(obj)

	c.attr("href":"/?q=#{obj.dept}+#{obj.num}")
	if !popover
		c.data("title",obj.name)
		c.data("placement","top")
		c.tooltip()
	else
		c.data("container","body")
		c.data("placement","auto left")
		c.data("content",obj.popover_content)
		c.data("title",obj.popover_title)
		c.addClass("pop")
		c.popover()

	courses.push(obj)

	if post
		course_ajax(obj, "add")

dept_and_cnum = (obj) ->
	"#{obj.dept} #{obj.num} #{type2name(obj.course_type, false, true)}"

find_course = (obj) ->
	for course, i in courses
		if course.crn == obj.crn
			return i
	return -1


conflicting_course = (obj) ->
	a = []
	for course in courses
		if obj.crn == course.crn
			return null
		if exists_conflict(obj, course) || exists_conflict(course, obj)
			a.push(course)
	return a

remove_section_obj = (obj, nopost) ->
	$(".b-#{obj.crn}").remove()

	idx = find_course(obj)
	courses.splice(idx,1) if idx > -1

	if !nopost
		course_ajax(obj, "delete")


root.remove_section = (btn) ->
	obj = $(btn).data('section')
	if (obj)
		remove_section_obj(obj)
		compute_buttons()
		resize_schedule()
		if !$(btn).hasClass('btn-success') && $(btn).hasClass('locked')
			$(btn).closest('.tooltippy').tooltip('show')


root.add_section = (btn) ->
	obj = $(btn).data('section')
	add_course(obj, false, true)
	compute_buttons()

root.undo_section = (btn) ->
	obj = $(btn).data('section')
	for conf in conflicting_course(obj)
		remove_section_obj(conf)

	add_section(btn)
	$(btn).parent().remove()

root.conflict_section = (btn) ->
	obj = $(btn).data('section')
	for conf in conflicting_course(obj)
		remove_section_obj(conf)
		undo = $(btn).parent().clone().find('button')
		undo.data("section",conf)
		undo.attr("id", "")
		undo.removeClass('btn-success').removeClass('btn-danger')
		undo.addClass('btn-warning').addClass('undo')
		undo.parent().appendTo($(btn).parent().parent())
		undo.html(if obj.course_type != MAIN then "Undo" else "Re-add #{dept_and_cnum(conf)}")
		undo.attr("onclick","undo_section(this);")

	add_section(btn)

format_btn = (btn, color, text, js, icons) ->
	$(btn).removeClass('btn-primary').removeClass('btn-danger').removeClass('btn-success')
	$(btn).closest('.tooltippy').tooltip('enable')

	$(btn).addClass(color)
	$(btn).attr("onclick", "#{js}_section(this);") if js

	if icons
		if $(btn).hasClass('locked')
			text += "<span class='course-icon glyphicon glyphicon-lock'></span>"
		if $(btn).hasClass('closed')
			text += "<span class='course-icon glyphicon glyphicon-ban-circle'></span>"

	$(btn).html(text)

	if js == "remove"
		# dd = $("<button class='btn btn-success dropdown-toggle add-course-special' data-toggle='dropdown' type='button'>
		# 			<span class='caret'></span>
		# 		</button>").dropdown()

		# menu = $("<ul class='dropdown-menu' role='menu'>
		# 	    	<li><a href='#'>Tentative</a></li>
		# 	    	<li><a href='#'>I'm TAing this course</a></li>
		# 		  </ul>")

		# dd.insertAfter(btn)
		# menu.insertAfter(dd)
		$(btn).closest('.tooltippy').tooltip('hide')
		$(btn).closest('.tooltippy').tooltip('disable')

root.compute_buttons = ->
	for btn in $('.add-course-btn, .lab-btn').not('.disabled').not('.undo')
		obj = $(btn).data('section')
		conflict = conflicting_course(obj)
		type = type2name(obj.course_type, false, false)
		if conflict == null
			format_btn(btn, "btn-success", "Remove #{if obj.course_type != MAIN then "" else type}", "remove")
		else if conflict.length > 0
			txt = conflict.map( (conf) ->
				dept_and_cnum(conf)
			).join(" and ")
			format_btn(btn, "btn-danger", "Conflict #{if obj.course_type == MAIN then "with #{txt}" else ""}", "conflict", true)
		else
			if obj.start_time
				format_btn(btn, "btn-primary", "Add #{type}", "add", true)
			else
				format_btn(btn, "btn-default", "Time & Place TBA", null, true)


root.hover = (btn) ->
	obj = $(btn).data('section')
	if !obj.start_time
		return

	if find_course(obj) > -1
		$(".b-#{obj.crn}").css("opacity",0.25)
		return

	if obj.start_time/100-5 < min || obj.end_time/100+5 > max
		resize_schedule(obj)

	op = 0.4
	if $(btn).hasClass('btn-danger')
		op = 0.83
	c = add_block(obj)
	c.css("opacity",op)

root.unhover = (btn) ->
	obj = $(btn).data('section')
	if !obj.start_time
		return
	
	if find_course(obj) > -1
		$(".b-#{obj.crn}").css("opacity",0.63)
		return

	$(".b-#{obj.crn}").remove()

	resize_schedule()
	
	
root.show_skedge = ->
	if $('.popup-skedge').length == 0
		$('.sk').clone().prependTo('.container').addClass('popup-skedge').hide()
	$('.popup-skedge').toggle()


###############
#bookmarks
################

bookmarks = []

bookmark_ajax = (id, action) ->
	ajax("bookmark/#{action}", id, 
		((is_new) -> ),
		( -> ))

root.bookmark = (btn) ->
	if $(btn).hasClass('enabled')
		$(".bookmarks-row-#{btn.id}").fadeOut(100)
		$(btn).removeClass('enabled')
		bookmark_ajax(btn.id, "delete")
	else
		add_bookmark($(btn).data('num'), $(btn).data('name'), btn.id).hide().fadeIn()
		bookmark_ajax(btn.id, "add")

root.toggleSide = () ->
	$(".sk").toggle()
	$(".bk").toggle()
	if $(".bk").is(":visible")
		#document.cookie = "bookmarks=1" #how to set an expiration date for this... (but not for s_id)
		$("#toggle-btn").html("Schedule")
	else
		#document.cookie = "bookmarks=0"
		$("#toggle-btn").html("Bookmarks")

$(document).ready ->
	if match = document.cookie.match(/bookmarks=(\d)/)
		if (match[1] == "1")
			toggleSide()

root.remove_bookmark = (btn,id) ->
	$(btn).closest('tr').fadeOut(100)
	$("##{id}").removeClass('enabled')
	bookmark_ajax(id, "delete")

root.add_bookmark = (num,name,id) ->
	$("##{id}").addClass('enabled')
	row = $("<tr class='bookmarks-row-#{id}'>
		<td class='check-td'>
			<div class='b-check'><input type='checkbox'></input></div>
		</td>
		<td>
			<a href='/?q=#{num}' class='b-a'>
				<div class='b-body'><strong>#{num}</strong><br>#{name}</div>
			</a>
		</td>
		<td>
			<button type='button' onclick='remove_bookmark(this, #{id}); return false;' class='close b-close' aria-hidden='true'>×</button>
		</td>
	</tr>")
	$('.bookies').append(row)
	row


#######################
#other stuff
#######################

root.prof_email = (i, link) ->
	$(link).closest('.dropdown-menu').dropdown('toggle')
	if $(link).find('img').length == 0
		spinner = $(link).append('<img src="assets/ajax-loader.gif" class="spinner" />')
		$.get("/getemail", {"email":i}, (data) ->
			$(link).html("<img src='#{data.url}' />")
		).fail( (data) ->
			$(link).html("<span class='text-danger'>Error retrieving email :(</span>").addClass('text-danger')
		)


root.render_img = (sid,goto) ->
	a = $('.screenshot').clone().appendTo('body')
	a.width(1000)
	a.find('.s-block-time, .s-block-title').show().css('display','block')
	a.find('.s-block-dept, .s-block-cnum, .s-block-type').css('display','inline')
	a.find('.s-block-p').css('line-height','1.1em').css('text-align','left').css('margin','8px 8px 2px 8px').css('display','block').css('color','white')
	a.find('.s-block-title').css('margin-top','3px').show()
	a.find('.wrapper').css('color','white')
	a.find('.s-big').css('display','block')
	a.find('.s-block').css('opacity','0.85')
	html2canvas(a, {
		onrendered: ( (canvas) ->
			strDataURI = canvas.toDataURL("image/jpeg")
			# console.log("ok here we go!!!!!!")
			$.post("schedule/#{sid}/set_image.json", {"img":strDataURI, "secret":secret}, (data) ->
				console.log("got this data #{data.url}")
				if (goto)
					window.location=data.url
			)
			a.remove()
		)
	})

pad = (num) ->
	if (num+"").length == 1
		return "0"+num
	return num+""

root.render_event = (obj) ->
	today = new Date()
	day = today.getDay()
	days = ["S","M","T","W","R","F","U"]

	while (obj.days.indexOf(days[day % days.length]) > -1)
		day += 1
		today = new Date(today.getTime() + 1000*60*60*24);

	today_str = "#{today.getFullYear()}#{pad(today.getMonth()+1)}#{pad(today.getDate())}"
	start = "#{today_str}T#{obj.start_time}00"
	end ="#{today_str}T#{obj.end_time}00"
	days = obj.days.split("").map((d) -> {"M":"MO","T":"TU","W":"WE","R":"TH","F":"FR","S":"SA","U":"SU"}[d]).join(",")
	[
		"BEGIN:VEVENT",
		"CLASS:PUBLIC",
		"DESCRIPTION:#{obj.name}",
		"DTSTART;TZID=America/New_York:#{start}",
		"DTEND;TZID=America/New_York:#{end}",
		"LOCATION:#{obj.location}",
		"SUMMARY;LANGUAGE=en-us:#{dept_and_cnum(obj)}",
		"TRANSP:TRANSPARENT",
		"RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=#{days};WKST=SU"
		"END:VEVENT",
	].join('\n')+'\n'

root.render_ics = ->
	cal = "BEGIN:VCALENDAR\nVERSION:2.0\n"
	for obj in courses
		cal += render_event(obj)
	cal += "END:VCALENDAR"
	
	blob = new Blob([cal])
	# if navigator.userAgent.indexOf('MSIE 10') > -1 # chrome or firefox
	# else  # ie
	#    	bb = new BlobBuilder()
	#    	bb.append(cal)
	#    	blob = bb.getBlob("text/x-vCalendar;charset=" + document.characterSet)
	saveAs(blob, "skedge.ics")

