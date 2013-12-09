require 'rubygems'
require 'mechanize'

class Department
	attr_accessor :name, :short, :courses
end

class Course
	attr_accessor :dept, :num, :name
end

a = Mechanize.new
a.get('https://cdcs.ur.rochester.edu/') do |page|
    form = page.form("form1")
    form.field_with(:name => "ddlTerm").option_with(:text => "Spring 2014").click
    form.field_with(:name => "ddlDept").option_with(:value => "CSC").click
    form.field_with(:name => "ddlTypes").option_with(:value => "0").click #main course
    form.field_with(:name => "ddlStatus").option_with(:value => "OP").click #open courses

    form.field_with(:name => "ddlCreditFrom").option_with(:value => " 00.1").click
    form.field_with(:name => "ddlCreditTo").option_with(:value => " 16.0").click

    results = form.click_button
    num = 1
    results.search("//table[@cellpadding='3']").each do |e|
    	xpath = "//span[@id='rpResults_ctl#{sprintf '%02d', num}_lblCNum']"
    	course = e.search(xpath).first
    	puts "xpath #{xpath} ="
    	puts course.text if course
    	num += 2
    end
end