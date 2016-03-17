require 'spec_helper'

describe "DataFormatter" do
  def test_title(cn="CSC 101", text, fixed)
    expect(DataFormatter::Course.title(text, cn)).to eq(fixed)
  end

  def test_instructor(instructors, fixed)
    expect(DataFormatter::Section.instructors(instructors)).to eq(fixed)
  end

  it "should unstick comments" do
    expect(DataFormatter::Course.comments("csc", nil, "1234WHEN")).to eq("1234 WHEN")
  end

  it "should downcase titles" do
    test_title "MAGIC’S METAPHORICAL MOMENTS", "Magic’s Metaphorical Moments"
    test_title "ALGEBRA III", "Algebra III"
    test_title "ALGEBRA IV", "Algebra IV"
    test_title "ALGEBRA OF A MAN", "Algebra of a Man"
    test_title "ALGEBRA A", "Algebra A"
    test_title "ALGEBRA MWF", "Algebra MWF"
    test_title "MISSING CUES: AN EXPLORATION OF NONVERBAL COMMUNICATION", "Missing Cues: An Exploration of Nonverbal Communication"
    test_title "TRUTH-TELLING AND NARRATIVE STYLE", "Truth-Telling and Narrative Style"
    test_title "PHY 113", "INTRO PHYS A", "Intro Phys" # special case
    test_title "ORGANIC CHM II:LAB LECTURE", "Organic CHM II: Lab Lecture"
    test_title "FRENCH IN FILM: AFRICA, CARIBBEAN, QUÉBEC", "French in Film: Africa, Caribbean, Québec"
    test_title "BEGINNING BALLET II/ADV BEGINNING BALLET", "Beginning Ballet II/Adv Beginning Ballet"
    test_title "HELLO OF/FOR SMTH", "Hello of/for Smth"
    test_title "HELLO&SMTH", "Hello & Smth"
    test_title "A HELLO&SMTH B", "A Hello & Smth B"
    test_title "REST IN PEACE? THE ROLES OF GHOSTS", "Rest in Peace? The Roles of Ghosts"
  end

  it "should fix instructor names" do
    test_instructor "JONES A", "Jones A"
    test_instructor "JONES A; GORP B", "Jones A; Gorp B"
    test_instructor "MCDONALDS", "McDonalds"
    test_instructor "MCDONALDS R", "McDonalds R"
    test_instructor "MCDONALDS-BURGER R", "McDonalds-Burger R"
    test_instructor "STJACQUES R", "St Jacques R"
    test_instructor "STANLEY", "Stanley"
    test_instructor "D'ANGELO", "D'Angelo"
    test_instructor "ONE-TWO R", "One-Two R"
  end
end