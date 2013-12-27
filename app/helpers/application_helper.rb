module ApplicationHelper
	def load_schedule(skedge, side, comparison=false)
		"#{comparison ? "$('.s-block').css('background-color','green');" : ""}
		#{!skedge ? "" : skedge.js_data.map{|a| "add_course(#{a}, #{!side}, false, #{comparison ? "\"blue\"" : "null"});"}.join("\n")}
		#{comparison ? "$('.s-block').css('opacity',0.63);" : ""}
		compute_buttons();"
	end
end
