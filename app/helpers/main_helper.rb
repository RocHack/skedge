module MainHelper
	Defaults = {"credits" => "Any", "term" => "Either", "sort" => "Course #"}

	def inline_form(link_text, query=link_text)
		form_tag("/", method:"post", class:"form-inline inline") do
			hidden = hidden_field_tag 'query', query #implicit field that will send the query (ie, query will go into \1)
			link = link_to link_text, "#", :onclick => "$(this).closest('form').submit()" #submit the closest form
			hidden + link
		end
	end

	def instructor_dropdown_action(i, action, text)
		"<li><a href='#'' onclick='#{action}(\"#{i}\"); return false;'>#{text}</a></li>"
	end

	def instructor_dropdown(i)
		i = i.split.first.downcase.strip
		raw('<ul class="dropdown-menu" role="menu">' +
			instructor_dropdown_action(i, "prof_email", "Email instructor") +
			instructor_dropdown_action(i, "prof_rmp", "Look up on Rate My Professors") +
			'<li class="divider"></li>' +
			instructor_dropdown_action(i, "prof_search", "Courses taught by this instructor") +
			'</ul>')
	end

	def should_split_cols(subcourses)
		subcourses.size > 3
	end

	def bracket_link(txt, link, hash={})
		raw("<span>[<span style='margin:0 2px 0 2px;'>" + link_to(txt, link, hash) + "</span>]</span>")
	end

	def get_filter(filter)
		params[filter] || Defaults[filter]
	end

	def fake_a(txt)
		link_to txt, "#", {onclick:"return false;"}
	end
end
