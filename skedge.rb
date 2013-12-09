#- rank courses by how important they are to you (value), so it can generate skedges

require 'rubygems'
require 'mechanize'

class Department
	attr_accessor :name, :short, :courses

	def initialize
		@courses = []
	end
end

class Course
	attr_accessor :dept, :num, :name, :desc, :instructors
	attr_accessor :building, :room, :days, :start_time, :end_time
end

class Scraper
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
		room:LabelSchedule+"lblRoom"}

	def get_dept(dept)
	    @form.field_with(:name => "ddlTerm").option_with(:text => "Spring 2014").click
	    @form.field_with(:name => "ddlDept").option_with(:value => dept.short).click
	    @form.field_with(:name => "ddlTypes").option_with(:value => "0").click #main course
	    @form.field_with(:name => "ddlStatus").option_with(:value => "OP").click #open courses

	    @form.field_with(:name => "ddlCreditFrom").option_with(:value => " 00.1").click
	    @form.field_with(:name => "ddlCreditTo").option_with(:value => " 16.0").click

	    results = @form.click_button
	    num = 1
	    results.search("//table[@cellpadding='3']").each do |e|
	    	c = Course.new
	    	c.dept = dept
	    	c.dept.courses << c	
	    	Labels.each do |sym, label|
		    	xpath = "//span[@id='rpResults_ctl#{sprintf '%02d', num}_#{label}']"
		    	val = e.search(xpath).first
		    	c.send((sym.to_s + "=").to_sym, val ? val.text : nil)
	    	end
	    	c.num = c.num.split.last
	    	num += 2
	    end
	end

	def run(num)
		depts = []

		a = Mechanize.new
		a.get('https://cdcs.ur.rochester.edu/') do |page|
			form = page.form("form1")
		    form.field_with(:name => "ddlSchool").option_with(:value => "1").click
		    results = form.click_button
			@form = results.form("form1")

			@form.field_with(:name => "ddlDept").options.each do |dept|
				d = Department.new
				d.name = dept.text.split(" - ", 2).last
				d.short = dept.value
				depts << d if depts.size < num && d.name && d.short
			end

			depts.each do |dept|
				get_dept(dept)
			end
		end

		depts
	end
end

depts = Scraper.new.run(1)
pp depts