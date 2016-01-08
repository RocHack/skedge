When(/^I search for "(.*?)"$/) do |search_term|
  @front_page.search_for search_term
end

Then(/^I should see its description as "(.*?)"$/) do |search_term|
  @front_page.contains search_term
end
