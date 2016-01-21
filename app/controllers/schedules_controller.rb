class SchedulesController < ApplicationController
  layout nil

  def get_svg
    svg = render_to_string "show.svg.erb", layout: false
    # strip outer div that react places around the SVG
    svg.gsub!(/<div.*?\">|<\/div>/, '')
    # get rid of reactid's
    svg.gsub!(/data-reactid=\".*?\"/, '')
    # replace the checksum with xmlns, which we can't include via react
    svg.gsub!(/data-react-checksum=\".*?\"/, 'xmlns="http://www.w3.org/2000/svg"')

    # add xml header
    "<?xml version=\"1.0\"?>\n" + svg
  end

  def send_converted_svg(svg, format)
    image = MiniMagick::Image.read(svg)
    image.format(format)
    send_data image.to_blob, type: "image/#{format}", disposition: 'inline'
  end

  def show
    @schedule = Schedule.find_by_rid(params[:rid])
    if current_user && @schedule && @schedule.user != current_user
      @user_schedule = current_user.schedules.find_by(yr_term:@schedule.yr_term)
    end
    @seen_alert = cookies['seen_alert']
    respond_to do |format|
      format.html
      format.ics { render layout: false }
      format.gcal { render "gcal.json.jbuilder", layout: false }
      format.svg { send_data get_svg, type: 'text/xml', disposition: 'inline' }
      format.jpg { send_converted_svg get_svg, "jpg" }
      format.png { send_converted_svg get_svg, "png" }
      format.json { render json:reactify_schedule(@schedule) }
    end
  end

  ### API

  def bookmark
    user = current_user
    if !user
      user = User.create
      ahoy.track("$new-user", {id:user.id, bookmark: true})
    end
    course = Course.find(params[:course_id])
    if user.bookmarked_courses.include?(course)
      user.bookmarked_courses.delete course
      ahoy.track("$bookmark", {add: false, course_id: course.id})
    else
      user.bookmarked_courses << course
      ahoy.track("$bookmark", {add: true, course_id: course.id})
    end
    user.save

    render json:{status:200, userSecret: user.secret}
  end

  def change_last_schedule
    user = current_user
    user.last_schedule_id = user.schedules.find_by(yr_term:params[:yrTerm]).id || raise
    user.save!
    render json:{status:200}
  end

  def add_drop_sections
    user = current_user
    if !user
      user = User.create
      ahoy.track("$new-user", {id:user.id})
    end
    params[:data].each do |crn, mod|
      section = Section.find_by_crn(crn)
      schedule = Schedule.find_or_create_by(user_id:user.id,
                                            yr_term:section.course.yr_term,
                                            term:section.course.term,
                                            year:section.course.year)

      if (mod.to_i == 1)
        schedule.sections << section
      else
        schedule.sections.delete section
      end
      schedule.save

      user.last_schedule_id = schedule.id
      user.save
    end
    render json:{status:200,
                 schedules:reactify_schedules(user.schedules),
                 userSecret:user.secret}
  end
end