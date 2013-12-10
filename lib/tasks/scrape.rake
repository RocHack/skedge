require 'rubygems'
require 'mechanize'

class Scraper
  #the resulting HTML is stuck in tables, and each info is kept in a span with its respective name...
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
    comments:"lblComments",
    crn:"lblCRN",
    restrictions:"lblRestrictions"}

  ASE = "1"

  attr_accessor :school, :term, :num

  def get_dept(dept)
    #make all the CDCS choices
    @form.field_with(:name => "ddlTerm").option_with(:text => @term).click
    @form.field_with(:name => "ddlDept").option_with(:value => dept.short).click
    @form.field_with(:name => "ddlTypes").option_with(:value => "0").click #main course
    @form.field_with(:name => "ddlStatus").option_with(:value => "OP").click #open courses

    @form.field_with(:name => "ddlCreditFrom").option_with(:value => " 00.1").click
    @form.field_with(:name => "ddlCreditTo").option_with(:value => " 16.0").click

    #go!
    results = @form.click_button
    num = 1

    #so the courses are each in a table with cellpadding 3. convenient i guess
    results.search("//table[@cellpadding='3']").each do |e|
      c = Course.new
      c.department = dept
      #for each label, ie, attribute, parse thru html and assign to the course obj
      Labels.each do |sym, label|
        xpath = "//span[@id='rpResults_ctl#{sprintf '%02d', num}_#{label}']" #=> rpResults_ctl03_lblTitle
        val = e.search(xpath).first
        if sym == :num && val
          c.num = val.text.split.last.to_i #cnum (ie, 171 in csc171 comes as "csc 171", so split it to get the last part)
        else
          if (sym == :enroll || sym == :cap || sym == :credits || sym == :crn) #all these are numbers
            val = (val ? val.text.to_i : 0)
          elsif val
            val = val.text
          end
          c.send((sym.to_s + "=").to_sym, val) #sym is :num, so we want to send num= with the val to the course
        end
      end
      if c.num != 0 && c.num
        c.save
      end
      num += 2 #for some reason they go up by twos...?
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

      puts "found #{depts.size} departments"
      depts.each do |dept|
        puts "scraping #{dept.short} - #{dept.name}"
        get_dept(dept)
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
  Course.destroy_all
  Scraper.scrape do |s|
    s.term = "Spring 2014"
    s.school = Scraper::ASE
    s.num = 15
  end
  # Scraper.scrape do |s|
  #   s.term = "Fall 2013"
  #   s.course_class = Course
  #   s.dept_class = Department
  #   s.school = Scraper::ASE
  #   s.num = -1
  # end
end