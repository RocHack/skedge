# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

style = (day,start,duration,color) -> 
	width = 20
	hour = 100/12.0
	height = duration * hour
	left = days.indexOf(day.toUpperCase())*width
	top = hour*start
	{
		"width":"20%",
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
colors = ["#FE9B00", "#17B9FA", "#1BCF11", "#672357", "#187697", "#5369B5"]
courses = []

s_id = null
secret = null

root = exports ? this

cookie = document.cookie
if cookie
	match = cookie.match(/s_id=(\d+)&(.*?)(;| |$)/)
	if match
		s_id = match[1]
		secret = match[2]

set_cookie = ->
	expdate = new Date()
	expdate.setTime(expdate.getTime() + (24 * 60 * 60 * 365 * 4)) #4 yrs lol
	document.cookie = "s_id=#{s_id}&#{secret}; expires=#{expdate.toUTCString()};"

add_block = (obj, col) ->
	blx = []
	if !col
		col = colors[color % colors.length]

	for day in obj.days.split("")
		s = style(day,obj.time_in_hours-9,obj.duration,col)
		c = $("#template").clone().addClass("b-#{obj.crn}").css(s).appendTo($('#courses'))
		c.find('.s-block-dept').html(obj.dept)
		c.find('.s-block-cnum').html(obj.num)
		c.find('.s-block-time').html(obj.time)
		c.find('.s-block-title').html(obj.name)
		c.find('.s-block-type').html(type2name(obj.course_type, true, true))
		blx.push(c)
	$(".b-#{obj.crn}")

ajax = (obj, action) -> 
	$.post("schedule/#{if s_id then s_id else "new"}/#{action}", {"crn":obj.crn, "secret":secret}, (data) ->
		if !s_id
			s_id = data.id
			secret = data.secret
			set_cookie()
			$('#share-link').attr("href","#{s_id}")
			$('#share-link').show()
	).fail ->
		remove_section_obj(obj, true)
		compute_buttons()
		alert("an error occurred - pls check your internet connection?")

root.add_course = (obj, popover, post, c) ->
	c = add_block(obj, c)
	if !popover
		c.attr("onclick":"$('#search-input').val('#{obj.dept} #{obj.num}'); $('#form').submit(); return false;")
		c.data("title",obj.name)
		c.tooltip()
	else
		c.data("content",obj.popover_content)
		c.data("title",obj.popover_title)
		c.addClass("pop")
		c.popover()
	courses.push(obj)
	color += 1

	if post
		ajax(obj, "add")

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
		ajax(obj, "delete")


root.remove_section = (btn) ->
	obj = $(btn).data('section')
	if (obj)
		remove_section_obj(obj)
		compute_buttons()

root.add_section = (btn) ->
	obj = $(btn).data('section')
	add_course(obj, false, true)
	compute_buttons()

root.undo_section = (btn) ->
	obj = $(btn).data('section')
	for conf in conflicting_course(obj)
		remove_section_obj(conf)

	add_section(btn)
	$(btn).remove()

root.conflict_section = (btn) ->
	obj = $(btn).data('section')
	for conf in conflicting_course(obj)
		remove_section_obj(conf)
		undo = $(btn).clone()
		undo.data("section",conf)
		undo.attr("id", "")
		undo.removeClass('btn-success').removeClass('btn-danger')
		undo.addClass('btn-warning').addClass('undo')
		undo.appendTo($(btn).parent())
		undo.html(if obj.course_type != MAIN then "Undo" else "Re-add #{dept_and_cnum(conf)}")
		undo.attr("onclick","undo_section(this);")

	add_section(btn)

format_btn = (btn, color, text, js) ->
	$(btn).removeClass('btn-primary').removeClass('btn-danger').removeClass('btn-success')
	$(btn).addClass(color)
	$(btn).find('.btn-title').html(text)
	$(btn).attr("onclick", "#{js}_section(this);")

root.compute_buttons = ->
	for btn in $('.add-course-btn, .lab-btn').not('.disabled').not('.undo')
		obj = $(btn).data('section')
		conflict = conflicting_course(obj)
		type = type2name(obj.course_type, false, false)
		if conflict == null
			format_btn(btn, "btn-success", "Remove #{type}", "remove")
		else if conflict.length > 0
			txt = conflict.map( (conf) ->
				dept_and_cnum(conf)
			).join(" and ")
			format_btn(btn, "btn-danger", "Conflict #{if obj.course_type == MAIN then "with #{txt}" else ""}", "conflict")
		else
			format_btn(btn, "btn-primary", "Add #{type}", "add")


root.hover = (btn) ->
	obj = $(btn).data('section')
	if find_course(obj) > -1
		$(".b-#{obj.crn}").css("opacity",0.3)
		return

	c = add_block(obj, null)
	c.css("opacity",0.4)

root.unhover = (btn) ->
	obj = $(btn).data('section')
	if find_course(obj) > -1
		$(".b-#{obj.crn}").css("opacity",0.75)
		return
			
	$(".b-#{obj.crn}").remove()
	