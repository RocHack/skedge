# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

style = (day,start,duration,color) -> 
	width = 20
	hour = 100/11.0 - 0.05
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
	conf = false
	for day in c1.days.split("")
		if c2.days.indexOf(day) > -1
			conf = true
	if !conf
		return false
	((c1.start_time >= c2.start_time && c1.start_time <= c2.end_time) || 
	(c1.end_time >= c2.start_time && c1.end_time <= c2.end_time))

days = ["M", "T", "W", "R", "F"]
color = 0
colors = ["#FE9B00", "#17B9FA", "#1BCF11", "#672357", "#CCEBAC", "#187697", "#5369B5"]
courses = []

root = exports ? this
root.add_course = (obj,popover) ->
	for day in obj.days.split("")
		s = style(day,obj.time_in_hours-10,obj.duration,colors[color % colors.length])
		c = $("#template").clone().addClass("b-#{obj.crn}").css(s).appendTo($('#courses'))
		c.find('#s-block-dept').html(obj.dept)
		c.find('#s-block-cnum').html(obj.num)
		c.find('#s-block-time').html(obj.time)
		c.find('#s-block-title').html(obj.name)
		if !popover
			c.attr("onclick":"$('#search-input').val('#{obj.dept} #{obj.num}'); $('#form').submit(); return false;")
		else
			c.data("content",obj.popover_content)
			c.data("title",obj.popover_title)
	courses.push(obj)
	color += 1

conflicting_course = (obj) ->
	for course in courses
		if obj.crn == course.crn
			return true
		if exists_conflict(obj, course) || exists_conflict(course, obj)
			return course
	return null

remove_section_obj = (obj) ->
	$(".b-#{obj.crn}").hide()
	courses.splice(courses.indexOf(obj),1)

root.remove_section = (btn) ->
	obj = $(btn).data('section')
	remove_section_obj(obj)
	compute_buttons()

root.add_section = (btn) ->
	obj = $(btn).data('section')
	add_course(obj)
	compute_buttons()

root.conflict_section = (btn) ->
	obj = $(btn).data('section')
	conf = conflicting_course(obj)

	remove_section_obj(conf)
	add_section(btn)
	undo = $(btn).clone()
	undo.data("section",conf)
	undo.removeClass('btn-success').addClass('btn-warning').addClass('undo')
	undo.appendTo($(btn).parent())
	undo.html("Re-add #{conf.dept} #{conf.num}")
	undo.attr("onclick","")
	undo.click( ->
		remove_section(btn)
		add_section(undo)
		$(undo).hide()
	)

format_btn = (btn, color, text, js) ->
	$(btn).removeClass('btn-primary').removeClass('btn-danger').removeClass('btn-success')
	$(btn).addClass(color)
	$(btn).html(text)
	$(btn).attr("onclick", "#{js}_section(this);")

root.compute_buttons = ->
	for btn in $('.add-course-btn').not('.disabled').not('.undo')
		obj = $(btn).data('section')
		conflict = conflicting_course(obj)
		if conflict == true
			format_btn(btn, "btn-success", "Remove Section", "remove")
		else if conflict
			format_btn(btn, "btn-danger", "Conflict with #{conflict.dept} #{conflict.num}", "conflict")
			$(btn).data("conflict", conflict)
		else
			format_btn(btn, "btn-primary", "Add Section", "add")


