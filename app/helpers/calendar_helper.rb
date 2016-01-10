module CalendarHelper
  include ActionView::Helpers::TextHelper

  def recurrence_rule(section)
    "FREQ=WEEKLY;INTERVAL=1;BYDAY="+ics_formatted_days(section)
  end

  def ics_formatted_days(section)
    section.days.chars.map do |day|
      {"M" => "MO",
       "T" => "TU",
       "W" => "WE",
       "R" => "TH",
       "F" => "FR",
       "S" => "SA",
       "U" => "SU"}[day]
    end.join(",")
  end

  def next_date(section, start_or_end, format=nil)
    date = Time.new.in_time_zone(-5)
    date = date.change(hour: section.hour(start_or_end),
                       min: section.minutes(start_or_end),
                       sec: 0)

    while !section.days.include? %w(U M T W R F S)[date.wday]
      date += 1.day
    end
    
    date.strftime(format || "%Y%m%dT%H%M%S")
  end

  def next_start_date(section, format=nil)
    next_date(section, :start, format)
  end

  def next_end_date(section, format=nil)
    next_date(section, :end, format)
  end
end