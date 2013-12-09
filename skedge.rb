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
	attr_accessor :dept, :num, :name
end

class Scraper
	LabelNum = "lblCNum"
	LabelTitle = "lblTitle"
	LabelInstructors = "lblInstructors"
	LabelDesc = "lblDesc"

	LabelSchedule = "rpSchedule_ctl01_"
	LabelScheduleDays = LabelSchedule+"lblDay"
	LabelScheduleStartTime = LabelSchedule+"lblStartTime"
	LabelScheduleBuilding = LabelSchedule+"lblBuilding"
	LabelScheduleRoom = LabelSchedule+"lblRoom"

	def get_dept(dept)
	    @form.field_with(:name => "ddlTerm").option_with(:text => "Spring 2014").click
	    @form.field_with(:name => "ddlDept").option_with(:value => "CSC").click
	    @form.field_with(:name => "ddlTypes").option_with(:value => "0").click #main course
	    @form.field_with(:name => "ddlStatus").option_with(:value => "OP").click #open courses

	    @form.field_with(:name => "ddlCreditFrom").option_with(:value => " 00.1").click
	    @form.field_with(:name => "ddlCreditTo").option_with(:value => " 16.0").click

	    get_attr = lambda do |e, num, lbl|
	    	xpath = "//span[@id='rpResults_ctl#{sprintf '%02d', num}_#{lbl}']"
	    	e.search(xpath).first.text
	    end

	    results = @form.click_button
	    num = 1
	    results.search("//table[@cellpadding='3']").each do |e|
	    	cnum = get_attr.call(e, num, LabelNum)
	    	if cnum
	    		c = Course.new
	    		c.dept = dept
	    		c.dept.courses << c
	    		c.num = cnum.split(" ").last
	    		c.name = get_attr.call(e, num, LabelTitle)
	    	end
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