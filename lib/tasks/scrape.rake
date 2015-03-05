require 'rubygems'
require 'mechanize'

class Scraper
  #the resulting HTML is stuck in tables, and each field is kept in a tag, with the field name as id...
  LabelSchedule = "rpSchedule_ctl01_"
  CourseLabels = 
  {
    number:"lblCNum", 
    title:"lblTitle", 
    description:"lblDesc",
    prereqs:"lblPrerequisites",
    cross:"lblCrossListed",
    credits:"lblCredits",
    comments:"lblComments",
    restrictions:"lblRestrictions",
    term:"lblTerm",
    year:"lblTerm",
    clusters:"lblClusters"
  }

  SectionLabels =
  {
    section_type:"lblCredits",
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

  Schools = {"ASE" => "1", "SIMON" => "2"}
  
  attr_accessor :schools, :terms, :num, :depts

  def pad_with_zero(num)
    num.to_s.rjust(2,"0")
  end

  def extract_attribute(e, num, label, sym, dept)
    id = "rpResults_ctl#{pad_with_zero(num)}_#{label}"
    val = e.search("//span[@id='#{id}']").first
    if val
      val = val.text.strip

      val = val.split.last if sym == :number || sym == :year  #"CSC 172", "Spring 2013" => "172", "2013"
      val = Section::Term::Terms[val.split.first] if sym == :term  #"Spring 2013" => "Spring" => 1
      val = (Section::Type::Types[val] || Section::Type::Course) if sym == :section_type
      val = Section::Status::Statuses[val] if sym == :status
      val = Course::Formatter.format_name(val) if sym == :title
      val = Course::Formatter.format_restrictions(val) if sym == :restrictions
      val = Course::Formatter.format_clusters(val) if sym == :clusters
      val = Course::Formatter.linkify(dept, val) if sym == :comments || sym == :cross || sym == :prereqs
      val = val.to_i if IntFields.include? sym #convert to int for some fields
      val = Course::Formatter.encode(val) if sym == :description
      val = val.split(";") if sym == :instructors
      val = val.split(", ") if sym == :clusters

      val
    else
      nil
    end
  end

  def extract(labels, e, num, dept)
    dict = {}
    labels.each do |sym, label|
      val = extract_attribute(e, num, label, sym, dept)
      dict[sym] = val if val
    end
    dict
  end

  def parse_course(e, num, dept)
    c_info = extract(CourseLabels, e, num, dept)
    c_info[:dept] = dept
    s_info = extract(SectionLabels, e, num, dept)

    type = s_info[:section_type]

    # if c_info[:title].downcase["lab"]
    #   #link to something
    #   return nil
    # end

    if c_info[:credits] == 0 && type == Section::Type::Course
      return nil
    end

    c = Course.find_or_initialize_by(c_info.slice(:number, :dept, :term, :year))
    if c.new_record?
      #if this is a new record and we're looking at a lab, something went wrong (course needs to be registered first...) so get outta here
      #not necessary since we'll scrape all main courses first
      #nevermind
      return if type != Section::Type::Course

      old_latest = Course.where(c_info.slice(:number, :dept).merge(:latest => true)).first
      if !old_latest || ((old_latest.year < c.year) || (old_latest.year == c.year && old_latest.term > c.term))
        if old_latest
          old_latest.latest = false
          old_latest.save
        end

        c.latest = true
      end
    end

    #now deal with the section
    relation = c.relation(type)

    s = relation.where(crn:s_info[:crn]).first
    if !s
      s = Section.new
      relation << s
    end

    s.update_attributes(s_info)
    s.save

    if type == Section::Type::Course
      #cache some values so we can sort faster
      if !c.min_enroll || s.enroll < c.min_enroll
        c.min_enroll = s.enroll
      end if s.enroll

      if !c.min_start || s.start_time < c.min_start
        c.min_start = s.start_time
      end if s.start_time

      if !c.max_start || s.start_time > c.max_start
        c.max_start = s.start_time
      end if s.start_time

      c.update_attributes(c_info) 
    end

    c.save
  end

  def get_dept(dept, term)
    # 5.times do |course_type|
      #make all the CDCS choices
      search_mode = :text
      if !term
        #search the latest
        @form.field_with(:name => "ddlTerm").value = @form.field_with(:name => "ddlTerm").options[1]
      else
        @form.field_with(:name => "ddlTerm").option_with(search_mode => term).click
      end
      @form.field_with(:name => "ddlDept").option_with(:value => dept).click
      # @form.field_with(:name => "ddlTypes").option_with(:value => course_type.to_s).click

      #go!
      results = @form.click_button
      
      num = 1
      results.search("//table[@cellpadding='3']").each do |e|
        parse_course(e, num, dept)
        num += 2 #for some reason the number in the div id's go up by two
      end
    # end
  end

  def get_dept_list
    depts = []
    @form.field_with(:name => "ddlDept").options.each do |dept|
      if dept.value && !dept.value.strip.empty?
        depts << dept.value
        Department.find_or_create_by(short:dept.value, name:dept.text.split(" - ", 2).last)
      end
    end
    depts
  end

  def run
    a = Mechanize.new
    custom = @depts
    a.get('https://cdcs.ur.rochester.edu/') do |page|
      #get the main CDCS form
      form = page.form("form1")

      @schools.each do |school|
        #click school (otherwise department list is huge)
        form.field_with(:name => "ddlSchool").option_with(:value => school).click
        #but we have to load the selection so it uses the updated department popup
        results = form.click_button
        
        @form = results.form("form1")
        @depts = get_dept_list
        custom ||= @depts

        @terms.each do |term|
          puts Scraper::Schools.key(school)
          puts "Starting scrape of #{term ? term : "latest term"} (#{depts.size} departments)"
          @depts[@num..-1].each_with_index do |dept,i|
            puts "#{i+1+@num}. #{dept.upcase}"
            get_dept(dept.upcase, term)
          end
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
  def scrape(terms=[nil])
    num = ENV['num'] || 0

    Scraper.scrape do |s|
      s.terms = terms
      s.schools = ENV['schools'] ? ENV['schools'].split(",").map{|s|Scraper::Schools[s.upcase]} : Scraper::Schools.values
      s.num = num.to_i
      s.depts = ENV['depts'].split(",") if ENV['depts']
    end
  end

  task :summer => :environment do
    scrape(["Summer #{ENV['year'] || Time.now.year}"])
  end

  task :winter => :environment do
    scrape(["Winter #{ENV['year'] || Time.now.year}"])
  end

  task :fall => :environment do
    scrape(["Fall #{ENV['year'] || Time.now.year}"])
  end

  task :spring => :environment do
    scrape(["Spring #{ENV['year'] || Time.now.year}"])
  end

  task :current => :environment do
    scrape
  end
end

