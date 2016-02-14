class ApiController < ApplicationController
  include ReactHelper

  def course
    course = Course.sk_query(params[:q]).order({yr_term: :desc}).first
    render json: reactify_course(course, false) # don't include sections, why would we
  end
end
