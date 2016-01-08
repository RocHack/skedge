When(/^I load the page$/) do
  @front_page ||= FrontPage.new
  @front_page.load
end

Then(/^I see expected elements$/) do
  @front_page.expect_elements
end

And(/^I follow the about link$/) do
  @front_page.show_about
end

Then(/^I see the about text$/) do
  @front_page.expect_about_text
end

And(/^I follow the search link$/) do
  @front_page.show_search
end

Then(/^I see the search text$/) do
  @front_page.expect_search_text
end

And(/^I follow the department link$/) do
  @front_page.show_department
end

Then(/^I see the department text$/) do
  @front_page.expect_department_text
end
