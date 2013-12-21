# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# 
# 		width = 20
# 		hour = 100/11.0 - 0.05
# 		height = duration * hour
# 		left = days.index(a.upcase)*width
# 		top = hour*start
# 		"
# 		width: 20%;
# 		left: #{left}%;
# 		top: #{top}%;
# 		height: #{height}%;
# 		"

style = (day,start,duration) -> 
	width = 20
	hour = 100/11.0 - 0.05
	height = duration * hour
	left = days.indexOf(day.toUpperCase())*width
	top = hour*start
	"
	width: 20%;
	left: #{left}%;
	top: #{top}%;
	height: #{height}%;
	"

days = ["M", "T", "W", "R", "F"]

root = exports ? this
root.add_course = (day,start,duration,name) ->
	style = style(day,start,duration)
	style