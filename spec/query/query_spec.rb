require 'spec_helper'

describe "Querying" do
  include QueryingConcern

  before do
    @csc = Department.create(short:"CSC", name:"Computer Science")
    @ant = Department.create(short:"ANT", name:"Anthropology")
    @mth = Department.create(short:"MTH", name:"Mathematics")
  end

  def assert_query_error(text)
    query = Course.text_to_query(text)
    expect(query.error).to be_present, "Expecting #{query} to have an error"
  end

  def assert_query(text, attrs, orders:[], joins:[], format_title:true)
    attrs[:credits] ||= { :> => "0" }
    attrs[:title] = Course.title_match(attrs[:title]) if attrs[:title] && format_title

    query = Course.text_to_query(text)
    expect(query.attrs).to eq(attrs)
    expect(query.orders).to eq(orders)#, "Query orders didn't match"
    expect(query.joins).to eq(joins)#, "Query joins didn't match"
    expect(query.error).to be_nil, "got `#{query.error}` on #{attrs} when not expecting an error"
  end

  singleton_class.send(:alias_method, :it_can_search_on, :it)

  it_can_search_on "new courses" do
    query = Course.text_to_query("csc")
    expect(query.new).to eq(false)
    expect(query.attrs).to eq({:department_id => @csc.id, :credits => {:> => "0"}})

    query = Course.text_to_query("new csc")
    expect(query.new).to eq(true)
    expect(query.attrs).to eq({:department_id => @csc.id, :credits => {:> => "0"}})

    assert_query_error "new csc 2016"
  end

  it_can_search_on "dept, number" do
    assert_query "CSC",
                 {department_id:@csc.id}

    assert_query "csc 1",
                  {department_id:@csc.id, number: "1%"}

    assert_query "csc 17",
                  {department_id:@csc.id, number: "17%"}

    assert_query "csc173",
                  {department_id:@csc.id, number:"173%"}
  end

  it_can_search_on "some full department names" do
    assert_query "math 162",
                  {department_id:@mth.id, number: "162%"}
  end

  it_can_search_on "honors, upper level writing, etc" do
    assert_query_error "w"

    assert_query "csc173h",
                  {department_id:@csc.id, number:"173%H%"}

    assert_query "csc173HW",
                  {department_id:@csc.id, number:"173%H%W%"}

    assert_query "csc173hello",
                  {department_id:@csc.id, number:"173%H%E%L%L%O%"}

    assert_query "csc173w",
                  {department_id:@csc.id, number:"173%W%"}

    assert_query "csc 17w",
                  {department_id:@csc.id, number:"17%W%"}   

    assert_query "csc 173w",
                  {department_id:@csc.id, number:"173%W%"}   

    assert_query "csc w",
                  {department_id:@csc.id, number:"%W%"}   

    assert_query "csc 17 w",
                  {department_id:@csc.id, number:"17%W%"}   

    assert_query "csc 173w w",
                  {department_id:@csc.id, number:"173%W%", title:"w"}   
  end

  it_can_search_on "title" do
    assert_query_error "ab"

    assert_query "programming",
                 {title:"programming"}

    assert_query "The Science of Data Structures",
                 {title:"The Science of Data Structures"}
   
    assert_query "Science  Data",
                 {title:"Science  Data"}

    assert_query "The fall of the roman empire",
                 {title:"The fall of the roman empire"}

    assert_query "politics of 1935",
                 {title:"politics of 1935"}
  end

  it_can_search_on "description" do
    assert_query "\"buddhism\"",
                 {description:"%buddhism%"}
  end

  it_can_search_on "instructor" do
    assert_query "173 taught by brown",
                 {number: "173%", sections:{instructors: "%BROWN%"}},
                 joins:[:sections]

    assert_query "courses taught by brown",
                 {sections:{instructors: "%BROWN%"}},
                 joins:[:sections]

    assert_query "taught by brown",
                 {sections:{instructors: "%BROWN%"}},
                 joins:[:sections]

    assert_query "173 professor brown",
                 {number: "173%", sections:{instructors: "%BROWN%"}},
                 joins:[:sections]

    assert_query "173 instructed brown",
                 {number: "173%", sections:{instructors: "%BROWN%"}},
                 joins:[:sections]

    assert_query "173 instructor brown",
                 {number: "173%", sections:{instructors: "%BROWN%"}},
                 joins:[:sections]

    # assert_query "173 taught by brown and searle",
    #              {number: "173%", sections:{instructors: "%BROWN%"}},
    #              joins:[:sections]

    # assert_query "173 taught by brown, searle",
    #              {number: "173%", sections:{instructors: "%BROWN%"}},
    #              joins:[:sections]
  end

  it_can_search_on "crosslist" do
    assert_query "csc x ant",
                 {department_id:@csc.id, crosslisted:"%ant%"}

    assert_query "csc x ant thing",
                 {department_id:@csc.id, crosslisted:"%ant%", title:"thing"}

    assert_query "csc x ant x wst",
                 {department_id:@csc.id, crosslisted:"%ant%", title:"x wst"}
  end

  it_can_search_on "time, size" do
    assert_query_error "early"
    assert_query_error "late"
    assert_query_error "early late"

    assert_query_error "csc early late"

    assert_query "csc late",
                 {department_id:@csc.id},
                 orders:["max_start desc nulls last"]

    assert_query "csc early",
                 {department_id:@csc.id},
                 orders:["min_start ASC nulls last"]

    assert_query "csc small",
                 {department_id:@csc.id},
                 orders:["min_enroll ASC nulls last"]
  end

  it 'can handle combinations' do
    assert_query "early csc fall",
                 {department_id:@csc.id, term:Course::Term::Fall},
                 orders:["min_start ASC nulls last"]

    assert_query "early small csc fall",
                 {department_id:@csc.id, term:Course::Term::Fall},
                 orders:["min_start ASC nulls last", "min_enroll ASC nulls last"]

    assert_query "early csc fall small",
                 {department_id:@csc.id, term:Course::Term::Fall},
                 orders:["min_start ASC nulls last", "min_enroll ASC nulls last"]

    assert_query "early csc small fall",
                 {department_id:@csc.id, term:Course::Term::Fall},
                 orders:["min_start ASC nulls last", "min_enroll ASC nulls last"]

    assert_query "small early csc fall",
                 {department_id:@csc.id, term:Course::Term::Fall},
                 orders:["min_enroll ASC nulls last", "min_start ASC nulls last"]

    assert_query "spring csc late",
                 {department_id:@csc.id, term:Course::Term::Spring},
                 orders:["max_start desc nulls last"]

    assert_query "late spring csc",
                 {department_id:@csc.id, term:Course::Term::Spring},
                 orders:["max_start desc nulls last"]

    assert_query "spring late csc",
                 {department_id:@csc.id, term:Course::Term::Spring},
                 orders:["max_start desc nulls last"]
  end

  it_can_search_on 'numbers' do
    assert_query_error "1"
    assert_query_error "17"

    assert_query "173",
                 {number: "173%"}

    assert_query "1734",
                 {title: "1734"}

    assert_query "56025",
                 {sections:{crn:56025}},
                 joins:[:sections]

    assert_query "123456",
                 {title: "123456"}

    assert_query "csc 173 programming",
                 {department_id:@csc.id, number:"173%", title:"programming"}

    assert_query "programming 173",
                 {number: "173%", title:"programming"}

  end

  it_can_search_on 'year, term' do
    assert_query_error "2014"
    assert_query_error "fall 2014"

    assert_query "2014 csc",
                {department_id:@csc.id, year:2014}

    assert_query "csc 173 2014",
                {department_id:@csc.id, number:"173%", year:2014}

    assert_query_error "fall"
    assert_query_error "spring"

    assert_query_error "fall spring"

    assert_query "csc fall spring",
                 {department_id:@csc.id, term:[Course::Term::Fall, Course::Term::Spring]}

    assert_query "csc fall",
                 {department_id:@csc.id, term:Course::Term::Fall}

    assert_query "csc spring",
                 {department_id:@csc.id, term:Course::Term::Spring}

    assert_query "csc summer",
                 {department_id:@csc.id, term:Course::Term::Summer}

    assert_query "summer 2016",
                 {year:2016, term:Course::Term::Summer}

    assert_query "summer",
                 {year:2016, term:Course::Term::Summer}

    assert_query "winter 2016",
                 {year:2016, term:Course::Term::Winter}

    assert_query "winter",
                 {year:2016, term:Course::Term::Winter}
  end

  it_can_search_on 'credits' do
    assert_query "csc 1-2 credits",
                 {department_id:@csc.id, credits:{:>= => "1", :<= => "2"}}

    assert_query "csc 3 credits",
                 {department_id:@csc.id, credits:"3"}

    assert_query "csc 1 credit",
                 {department_id:@csc.id, credits:"1"}

    assert_query "csc credits 1-2",
                 {department_id:@csc.id, credits:{:>= => "1", :<= => "2"}}

    assert_query "csc credits: 1-2",
                 {department_id:@csc.id, credits:{:>= => "1", :<= => "2"}}

    assert_query "csc 0 credits",
                 {department_id:@csc.id, credits:"0"}

    assert_query "csc 0.5 credits",
                 {department_id:@csc.id, credits:"0.5"}

    assert_query "csc credits:0.5",
                 {department_id:@csc.id, credits:"0.5"}
  end

  it 'can handle edge cases' do
    assert_query "/|*+?{}()[]'\"_%",
                 {title:QueryingConcern::TitleMatchPrefix +
                        "/\\|\\*\\+\\?\\{\\}\\(\\)\\[\\]\\'\\\"\\_\\%" + 
                        QueryingConcern::TitleMatchSuffix},
                 format_title:false

    assert_query "®ª™•ºˆ∂ƒ∆˙¨∑´¥©•ª∂œ•º≈–ø˚",
                 {title:"®ª™•ºˆ∂ƒ∆˙¨∑´¥©•ª∂œ•º≈–ø˚"}
  end
end
