json.sections @schedule.sections do |section|
  json.summary section.course.department.short + " " + section.course.number
  json.location section.decorate.place
  json.description section.course.title

  json.start do
    json.dateTime next_start_date(section, "%Y-%m-%dT%H:%M:%S%z")
    json.timeZone "America/New_York"
  end

  json.end do
    json.dateTime next_end_date(section, "%Y-%m-%dT%H:%M:%S%z")
    json.timeZone "America/New_York"
  end

  json.recurrence ["RRULE:"+recurrence_rule(section)]
end