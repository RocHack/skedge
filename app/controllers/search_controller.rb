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
    when "bookmarks"
      ahoy.track "$bookmarks"
      if !current_user || current_user.bookmarked_courses.empty?
        @search_error = "You haven't bookmarked any courses yet!"
      else
        @course_groups = {group: current_user.bookmarked_courses}
        @bookmarks = true
      end
      render 'results'
    else
      begin
        sk_query = Course.sk_query(@query)
        @course_groups = sk_query.group_by(&:yr_term)
        if @course_groups.any? and !@course_groups[20171] and !sk_query.where_values_hash["term"]
          @course_groups[20171] = {groupName: "Fall 2016", text: "No courses found for Fall 2016."}
        end
      rescue Course::QueryingException => e
        @search_error = e.message
      end

      render 'results'
    end
  end
end