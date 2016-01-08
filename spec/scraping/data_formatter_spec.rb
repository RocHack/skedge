require 'spec_helper'

describe "DataFormatter" do
  def test_linkify(dept="CSC", num=nil, text, linkified)
    expect(DataFormatter::Course.linkify(dept, num, text)).to eq(linkified)
  end

  def test_title(cn="CSC 101", text, fixed)
    expect(DataFormatter::Course.title(text, cn)).to eq(fixed)
  end

  it "should linkify" do
    test_linkify "You need a 121 to graduate.", "You need a <a href='/?q=CSC+121'>121</a> to graduate."
    test_linkify "You need CSC 121 to graduate.", "You need <a href='/?q=CSC+121'>CSC 121</a> to graduate."
    test_linkify "You need CSC 121A to graduate.", "You need <a href='/?q=CSC+121A'>CSC 121A</a> to graduate."
    test_linkify "You need CSC121 to graduate.", "You need <a href='/?q=CSC121'>CSC121</a> to graduate."
    test_linkify "You need CSC121,122 to graduate.", "You need <a href='/?q=CSC121'>CSC121</a>,<a href='/?q=CSC+122'>122</a> to graduate."
    test_linkify "You need CSC121/122 to graduate.", "You need <a href='/?q=CSC121'>CSC121</a>/<a href='/?q=CSC+122'>122</a> to graduate."
    test_linkify "You need 12345 to graduate.", "You need <a href='/?q=12345'>12345</a> to graduate."
    test_linkify "You need 123 to graduate.", "You need <a href='/?q=CSC+123'>123</a> to graduate."
    test_linkify "CSC", "121", "You probably want CSC 399, 400 for this", "You probably want <a href='/?q=CSC+399'>CSC 399</a>, <a href='/?q=CSC+400'>400</a> for this"
    test_linkify "CSC", "221", "The 400 level of this class...", "The <a href='/?q=CSC+421'>400</a> level of this class..."
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
  end
end