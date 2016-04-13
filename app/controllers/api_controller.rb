class ApiController < ApplicationController
  include ReactHelper

  def course
    course = Course.sk_query(params[:q]).order({yr_term: :desc}).first
    render json: reactify_course(course, false) # don't include sections, why would we
  end

  def courses
    if params[:q].blank?
      render json: {error: "No query specified. Specify one with the 'q' param. Include sections by setting the 'sections' param (e.g. sections=1)"}
      return
    end

    begin
      include_sections = params[:sections].present?
      json = {}
      Course.sk_query(params[:q]).group_by(&:yr_term).each do |yrterm, collection|
        json[yrterm] = reactify_courses(collection, include_sections)
      end

      render json: json
    rescue Course::QueryingException => e
      render json: {error: e.message}
    end
  end

  def departments
    json = {}

    Department.all.group_by do |dept|
      Department::FormatSchool[dept.school]
    end.each do |school, depts|
      json[school] = depts.map do |dept|
        reactify_department(dept)
      end
    end

    render json: json
  end

end
