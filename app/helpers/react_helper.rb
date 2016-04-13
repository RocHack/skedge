module ReactHelper
  include ActionView::Helpers::TextHelper
  def reactify_department(dept)
    {
      name: dept.name,
      short: dept.short,
      id: dept.id
    }
  end

  def reactify_course(c, include_sections=true)
    {
      title: c.title,
      dept: c.department.short,
      num: c.number,
      id: c.id,
      term: Course::FormatTerm[c.term],
      year: c.year,
      yrTerm: c.yr_term,
      credits: c.credits,
      description: c.description ? c.description : nil,
      descriptionTruncated: truncate(c.description, length: 400),
      crosslisted: c.crosslisted,
      prerequisites: (c.prereqs.try(:downcase) == "none" ? nil : c.prereqs),
      restrictions: (c.restrictions.try(:downcase) == "none" ? nil : c.restrictions),
      comments: c.comments,
      requiresCode: c.requires_code?,
      sections: !include_sections ? nil : reactify_sections(c.course_sections, c),
      subcourses: !include_sections ? nil : {
        lab: reactify_sections(c.labs, c).group_by {|x| x[:abcSection]},
        labLecture: reactify_sections(c.lab_lectures, c).group_by {|x| x[:abcSection]},
        recitation: reactify_sections(c.recitations, c).group_by {|x| x[:abcSection]},
        workshop: reactify_sections(c.workshops, c).group_by {|x| x[:abcSection]}
      }
    } if c
  end

  def reactify_courses(courses, include_sections=true)
    courses.map do |course|
      reactify_course(course, include_sections)
    end if courses
  end

  def reactify_course_groups(course_groups)
    course_groups.keys.sort.reverse.map do |k|
      group = course_groups[k]
      group.is_a?(Hash) ? group : reactify_courses(group)
    end if course_groups
  end

  def reactify_section(s, course=nil)
    {
      duration: s.duration,
      startTime: s.start_time,
      endTime: s.end_time,
      startTimeHours:s.time_in_hours(:start),
      prettyTime: s.decorate.pretty_time(false),
      days: s.days,
      crn: s.crn,
      id: s.id,
      status: s.status,
      abcSection: s.abc_section,
      abcWeek: s.abc_week,
      instructors: s.instructors || "TBA",
      sectionType: s.section_type,
      enrollRatio: "#{s.enroll}/#{s.no_cap? ? "∞" : s.cap}",
      enrollBarPercentage: s.decorate.enroll_percent,
      timeAndPlace: s.decorate.time_and_place,
      place: s.decorate.place,
      course: reactify_course(course || s.course, false)
    }
  end

  def reactify_sections(sections, include_course=nil)
    sections.map do |section|
      reactify_section(section, include_course)
    end if sections
  end

  def reactify_schedule(schedule)
    {
      yrTerm: schedule.yr_term,
      term: Course::FormatTerm[schedule.term],
      year: schedule.year,
      sections: reactify_sections(schedule.sections),
      rid: schedule.rid,
      totalCredits: schedule.total_credits
    } if schedule
  end

  def reactify_schedules(schedules)
    hash = {}
    schedules.each do |schedule|
      hash[schedule.yr_term] = reactify_schedule(schedule)
    end if schedules
    hash
  end

  def reactify_yr_term_mappings(schedules)
    hash = {}
    schedules.map do |schedule|
      hash[schedule.yr_term] = "#{schedule.term} #{schedule.year}"
    end if schedules
    hash
  end

  def reactify_requests(requests)
    requests.map do |request|
      {
        id: request.id,
        to: request.user_b.fb_id,
        from: request.user_a.fb_id
      }
    end if requests
  end

  def reactify_users(users)
    users.map do |user|
      {
        id: user.id,
        fb_id: user.fb_id,
        schedules: reactify_schedules(user.schedules).values,
        likes: reactify_courses(user.liked_courses),
        privacy: user.public_sharing ? 0 : 1
      }
    end if users
  end

  def reactify_social(user)
    return nil if !user
    a = {
      fb_id: user.fb_id,
      shareUsers: reactify_users(user.share_users),
      requests: reactify_requests(user.share_requests),
      requested: reactify_requests(user.sent_share_requests),
      privacy: user.public_sharing ? 0 : 1,
      likes: reactify_courses(user.liked_courses),
      friendCount: user.friend_count
    }
    #don't get privately sharing, strictly public
    a[:publicFriends] = reactify_users(sharing_users(params[:friends], user, false)) if params[:friends]
    a
  end
end