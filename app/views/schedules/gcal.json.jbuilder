json.sections @schedule.sections do |section|
  json.summary section.course.department.short + " " + section.course.number
  json.location section.decorate.place
  json.description section.course.title

  json.start do
    json.dateTime section.decorate.next_start_date("%Y-%m-%dT%H:%M:%S%z")
    json.timeZone "America/New_York"
  end

  json.end do
    json.dateTime section.decorate.next_end_date("%Y-%m-%dT%H:%M:%S%z")
    json.timeZone "America/New_York"
  end

  json.recurrence ["RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY="+section.decorate.ics_formatted_days]
end