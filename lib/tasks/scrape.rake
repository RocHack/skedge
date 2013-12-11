require 'rubygems'
require 'mechanize'

class Scraper
  #the resulting HTML is stuck in tables, and each field is kept in a tag, with the field name as id...
  LabelSchedule = "rpSchedule_ctl01_"
  Labels = {
    num:"lblCNum", 
    name:"lblTitle", 
    instructors:"lblInstructors", 
    desc:"lblDesc",
    days:LabelSchedule+"lblDay", 
    start_time:LabelSchedule+"lblStartTime", 
    end_time:LabelSchedule+"lblEndTime",
    building:LabelSchedule+"lblBuilding", 
    room:LabelSchedule+"lblRoom",
    enroll:"lblTotEnroll",
    cap:"lblTotalCap",
    prereqs:"lblPrerequisites",
    cross_listed:"lblCrossListed",
    credits:"lblCredits",
    course_type:"lblCredits",
    comments:"lblComments",
    crn:"lblCRN",
    restrictions:"lblRestrictions",
    term:"lblTerm",
    year:"lblTerm",
    clusters:"lblClusters",
    status:"lblStatus"}

  IntFields = [:num, :enroll, :cap, :credits, :crn, :year]

  ASE = "1"

  attr_accessor :school, :terms, :num

  def pad_with_zero(num)
    num.to_s.rjust(2,"0")
  end

  def parse_course(e, num)
    c = Course.new

    #for each label, ie, attribute, parse thru html and assign to the course obj
    Labels.each do |sym, label|
      xpath = "//span[@id='rpResults_ctl#{pad_with_zero(num)}_#{label}']" #=> rpResults_ctl03_lblTitle
      val = e.search(xpath).first.try(:text)
      if val
        val.strip!

        val = val.split.last if sym == :num || sym == :year  #"CSC 172", "Spring 2013" => "172", "2013"
        val = val.split.first if sym == :term  #"Spring 2013" => "Spring" => 1
        val = (Course::Type::Types[val] || Course::Type::Course) if sym == :course_type
        val = Course::Status::Statuses[val] if sym == :status

        #convert to int for some fields
        val = val.to_i if IntFields.include? sym

        #call the setter method (ie :num=), with the val as the parameter
        c.send :"#{sym}=", val
      end
    end

    return nil if (c.num == 0 || c.num == nil || (c.course_type == Course::Type::Course && c.credits == 0))
    
    c
  end

  def get_dept(dept, term)
    #make all the CDCS choices
    @form.field_with(:name => "ddlTerm").option_with(:text => term).click
    @form.field_with(:name => "ddlDept").option_with(:value => dept.short).click
    @form.field_with(:name => "ddlStatus").option_with(:value => "OP").click #open courses

    #go!
    results = @form.click_button
    
    num = 1
    results.search("//table[@cellpadding='3']").each do |e|
      c = parse_course(e, num)
      if c
        c.department = dept
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

task :scrape => :environment do
  num = ENV['num'] || -1
  Scraper.scrape do |s|
    s.terms = ["Spring 2014", "Fall 2013"]
    s.school = Scraper::ASE
    s.num = num.to_i
  end
end