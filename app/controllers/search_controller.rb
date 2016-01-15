class SearchController < ApplicationController
  layout 'main'

  def search
    @query = params[:q].strip

    case @query.downcase
    when ""
      redirect_to :root
    when "registrar", "registrer", "registration", "register"
      ahoy.track "$fast", {location:"registrar"}
      redirect_to "https://webreg.its.rochester.edu/prod/web/RchRegDefault.jsp"
    when "cdcs"
      ahoy.track "$fast", {location:"cdcs"}
      redirect_to "https://cdcs.ur.rochester.edu/"
    else
      begin
        sk_query = Course.sk_query(@query)
        @course_groups = sk_query.group_by(&:yr_term)
      rescue Course::QueryingException => e
        @search_error = e.message
      end

      render 'results'
    end
  end
end