module MainHelper
	def inline_form
		form_tag("/", method:"post", class:"form-inline inline") do
			hidden = hidden_field_tag 'query', '\1', class:"inline"
			link = link_to '\1', "#", :onclick => "$(this).closest('form').submit()", class:"inline"
			hidden + link
		end
	end

	def formatted_prereqs(course)
		raw(course.prereqs.gsub(/([A-Za-z]*\s+\d+[A-Za-z]*)/, inline_form.strip)) #strip off some whitespace that seems to come w the form
	end
end
