class FrontPage < BasePage
  def load
    # visit 'http://stage.skedgeur.com'
    visit 'http://localhost:3000'
    self
  end

  def expect_elements
    expect(page).to have_content("skedge")
  end

  def show_about
    click_link('about')
  end

  def expect_about_text
    expect(page).to have_content("is a student-made alternative to the official")
  end

  def show_search
    click_link('search')
  end

  def expect_search_text
    expect(page).to have_content("some ways you can search")
  end

  def show_department
    click_link('departments')
  end

  def expect_department_text
    expect(page).to have_content("CSC – Computer Science")
  end

  def search_for term
    fill_in('q', :with => term + "\n")
  end

  def contains text
    expect(page).to have_content(text)
  end
end
