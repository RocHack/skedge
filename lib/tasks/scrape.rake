require 'rubygems'
require 'mechanize'

class Formatter
  def self.formatted_name(name)
    little = %w(and of or the to the in but as is for with)
    big = %(HIV AIDS GPU HCI VLSI VLS CMOS EAPP)
    prev = nil
    name.gsub(/(\w|\.|')*/) do |w|
      w2 = if little.include?(w.downcase) && prev && !prev.match(/:|-|–$/)
        w.downcase
      elsif big.include?(w.upcase)
        w.upcase
      elsif w =~ /^(I*|\d)([A-D]|V|)((:|\b)?)$/ || w =~ /^([A-Z]\.)*$/ || w =~ /^M?T?W?R?F?$/
        w
      else
        w.capitalize
      end
      prev = w2 if !w2.strip.empty?
      w2
    end
  end
end

class Scraper
  #the resulting HTML is stuck in tables, and each field is kept in a tag, with the field name as id...
  LabelSchedule = "rpSchedule_ctl01_"
  CourseLabels = 
  {
    num:"lblCNum", 
    name:"lblTitle", 
    desc:"lblDesc",
    prereqs:"lblPrerequisites",
    cross_listed:"lblCrossListed",
    credits:"lblCredits",
    course_type:"lblCredits",
    comments:"lblComments",
    restrictions:"lblRestrictions",
    term:"lblTerm",
    year:"lblTerm",
    clusters:"lblClusters"
  }

  SectionLabels =
  {
    instructors:"lblInstructors", 
    days:LabelSchedule+"lblDay", 
    start_time:LabelSchedule+"lblStartTime", 
    end_time:LabelSchedule+"lblEndTime",
    building:LabelSchedule+"lblBuilding", 
    room:LabelSchedule+"lblRoom",
    sec_enroll:"lblSectionEnroll",
    sec_cap:"lblSectionCap",
    tot_enroll:"lblTotEnroll",
    tot_cap:"lblTotalCap",
    crn:"lblCRN",
    status:"lblStatus"
  }

  IntFields = [:sec_enroll, :sec_cap, :tot_enroll, :tot_cap, :credits, :crn, :year]

  ASE = "1"

  attr_accessor :school, :terms, :num, :depts

  def pad_with_zero(num)
    num.to_s.rjust(2,"0")
  end

  def extract_attribute(e, num, label, sym)
    id = "rpResults_ctl#{pad_with_zero(num)}_#{label}"
    val = e.search("//span[@id='#{id}']").first
    if val
      val = val.text.strip

      val = val.split.last if sym == :num || sym == :year  #"CSC 172", "Spring 2013" => "172", "2013"
      val = Course::Term::Terms[val.split.first] if sym == :term  #"Spring 2013" => "Spring" => 1
      val = (Course::Type::Types[val] || Course::Type::Course) if sym == :course_type
      val = Section::Status::Statuses[val] if sym == :status
      val = Formatter.formatted_name(val) if sym == :name
      val = val.to_i if IntFields.include? sym #convert to int for some fields

      val
    else
      nil
    end
  end

  def extract_and_set(labels, obj, e, num)
    labels.each do |sym, label|
      val = extract_attribute(e, num, label, sym)
      if val
        #call the setter method (ie :num=), with the val as the parameter
        obj.send :"#{sym}=", val
      end
    end
  end

  def parse_course(e, num, dept)
    name = extract_attribute(e, num, CourseLabels[:name], :name)
    cnum = extract_attribute(e, num, CourseLabels[:num], :num)
    term = extract_attribute(e, num, CourseLabels[:term], :term)
    year = extract_attribute(e, num, CourseLabels[:year], :year)

    c = Course.find_or_create_by(name:name, num:cnum, department_id:dept.id, term:term, year:year)
    c.department = dept
    c.short = dept.short

    #for each label, ie, attribute, parse thru html and assign to the course obj
    extract_and_set(CourseLabels, c, e, num)

    #ignore course classes w/0 credits (they are like "independent study" etc)
    return nil if (c.course_type == Course::Type::Course && c.credits == 0)
    
    c
  end

  def self.link_subcourses
    Course.where {course_type != Course::Type::Course}.each do |c|
      c.main_course = find_main_course(c)
      c.sections.each do |s|
        s.main_course_id = c.main_course_id
        s.save
      end
      c.save
    end
  end

  def self.link_sister_courses
    Course.where {course_type == Course::Type::Course}.each do |c|
      c.sister_course = find_sister_course(c)
      c.save
    end
  end

  def self.find_main_course(c)
    Course.where do
      (term == c.term) &
      (year == c.year) &
      (num =~ c.num.to_i.to_s) &
      (department_id == c.department_id) &
      (course_type == Course::Type::Course) &
      (main_course_id == nil)
    end.first
  end

  def self.find_sister_course(c)
    t = (c.term + 1) % 2
    Course.where do
      (term == t) &
#      (year == c.year) & #if we only keep track of one semester behind, commented out is ok, otherwise has to be +/-
      (num == c.num) &
      (department_id == c.department_id) &
      (course_type == Course::Type::Course)
    end.first
  end

  def get_dept(dept, term)
    #make all the CDCS choices
    @form.field_with(:name => "ddlTerm").option_with(:text => term).click
    @form.field_with(:name => "ddlDept").option_with(:value => dept.short).click

    #go!
    results = @form.click_button
    
    num = 1
    results.search("//table[@cellpadding='3']").each do |e|
      c = parse_course(e, num, dept)
      if c
        #check if this is really a lab but in CDCS as a course
        if c.course_type == Course::Type::Course && c.name.downcase["lab"]
          mc = Scraper.find_main_course(c)
          if mc
            c.main_course = mc
            c.course_type = Course::Type::Lab
          end
        end

        #add this section to it
        crn = extract_attribute(e, num, SectionLabels[:crn], :crn)
        s = Section.find_or_create_by(crn:crn)
        s.course = c
        s.term = c.term
        s.course_type = c.course_type
        
        extract_and_set(SectionLabels, s, e, num)

        s.save

        #"cache" a copy of instructors on course so it's faster to search
        if s.instructors
          c.instructors ||= ""
          c.instructors += s.instructors + "; " unless c.instructors[s.instructors]
        end

        if !c.min_enroll || s.enroll < c.min_enroll
          c.min_enroll = s.enroll
        end

        if !c.min_start_time || s.start_time < c.min_start_time
          c.min_start_time = s.start_time
        end

        if !c.max_start_time || s.start_time > c.max_start_time
          c.max_start_time = s.start_time
        end

        c.save
      end
      num += 2 #for some reason the number in the div id's go up by two
    end
  end

  def get_dept_list
    depts = []
    @form.field_with(:name => "ddlDept").options.each do |dept|
      next if depts.size >= @num && @num > 0
      d = Department.where({short:dept.value}).first
      if !d
        d = Department.new
        d.name = dept.text.split(" - ", 2).last
        d.short = dept.value
        d.save
      end
      depts << d if d.name && d.short
    end
    depts
  end

  def run
    a = Mechanize.new
    a.get('https://cdcs.ur.rochester.edu/') do |page|
      #get the main CDCS form
      form = page.form("form1")
      #click school of arts & sciences (otherwise department list is huge)
      form.field_with(:name => "ddlSchool").option_with(:value => @school).click
      #but we have to load the selection so it uses the updated department popup
      results = form.click_button
      
      @form = results.form("form1")
      depts = get_dept_list 
      depts = @depts.map {|d| Department.find_by_short(d.upcase)} if @depts
      
      @terms.each do |term|
        puts "Starting scrape of #{term} (#{depts.size} departments)"
        depts.each_with_index do |dept,i|
          puts "#{i+1}. #{dept.short} - #{dept.name}"
          get_dept(dept, term)
        end
      end
    end
  end

  def self.scrape
    s = Scraper.new
    yield s
    s.run
  end
end

namespace :scrape do
  task :fetch => :environment do
    num = ENV['num'] || -1
    Scraper.scrape do |s|
      s.terms = ["Spring 2014", "Fall 2013"]
      s.school = Scraper::ASE
      s.num = num.to_i
      s.depts = ENV['depts'].split(",") if ENV['depts']
    end
  end

  task :subcourses => :environment do
    puts "Linking labs/lectures/recitations/workshops to their main courses..."
    Scraper.link_subcourses
  end

  task :sister => :environment do
    puts "Linking sister courses..."
    Scraper.link_sister_courses
  end

  task :all => :environment do
    Rake::Task["scrape:fetch"].invoke
    Rake::Task["scrape:subcourses"].invoke
    Rake::Task["scrape:sister"].invoke
  end
end

