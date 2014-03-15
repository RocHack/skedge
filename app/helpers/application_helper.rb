module ApplicationHelper
	def load_user(user, skedge)
		# "#{comparison ? "$('.s-block').css('background-color','green');" : ""}
		# "#{!skedge ? "" : skedge.js_data.map{|a| "add_course(#{a}, #{!side}, false, #{comparison ? "\"blue\"" : "null"});"}.join("\n")}
		# #{comparison ? "$('.s-block').css('opacity',0.63);" : ""}
		"load_user(#{user}, #{skedge});
		compute_buttons();"
	end

	def load_bookmarks(skedge)
		return "" if !skedge
		puts "bookies = #{skedge.bookmarks}"
		skedge.bookmarks.map {|c| "add_bookmark(#{c.to_json});"}.join("\n")
	end
end
