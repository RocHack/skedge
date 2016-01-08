require 'spec_helper'

describe "Course" do
  it "should properly parse yrterm into year and term" do
    yr, term = Course.yr_term_to_year_and_term(20161)
    expect(yr).to eq(2015)
    expect(term).to eq(Course::Term::Fall)

    yr, term = Course.yr_term_to_year_and_term(20162)
    expect(yr).to eq(2016)
    expect(term).to eq(Course::Term::Spring)

    yr, term = Course.yr_term_to_year_and_term(20163)
    expect(yr).to eq(2016)
    expect(term).to eq(Course::Term::Winter)

    yr, term = Course.yr_term_to_year_and_term(20164)
    expect(yr).to eq(2016)
    expect(term).to eq(Course::Term::Summer)
  end
end