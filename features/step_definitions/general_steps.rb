Given(/^I am a Skedge user$/) do
  @user = User.find_or_create_by(secret:"abc")
end

