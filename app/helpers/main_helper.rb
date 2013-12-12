module MainHelper
	def inline_form(link_text, query=link_text)
		form_tag("/", method:"post", class:"form-inline inline") do
			hidden = hidden_field_tag 'query', query #implicit field that will send the query (ie, query will go into \1)
			link = link_to link_text, "#", :onclick => "$(this).closest('form').submit()" #submit the closest form
			hidden + link
		end
	end

	def should_split_cols(subcourses)
		subcourses.size > 3
	end
end
