describe "scheduling" do
  it "lets me add courses" do
    visit '/?q=csc+172'
    
    # print page.html
    page.should have_no_selector("#share-link")

    # first(".add-course-btn").click

    # find("#share-link")

    # click_link 'Sign in'
    # expect(page).to have_content 'Success'
  end
end