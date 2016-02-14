class ApiController < ApplicationController
  include ReactHelper

  def course
    course = if params[:crn]
      Section.find_by(crn: params[:crn]).course
    elsif params[:number] && params[:dept]
      Course.where({
        department_id: Department.find_by_short(params[:dept]).id,
        number: params[:number]
      }).order({yr_term: :desc}).first
    end
    render json: reactify_course(course, false) # don't include sections, why would we
  end
end
