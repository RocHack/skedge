module SectionDecorator
  DaysOfWeek = {"M" => "Mon", "T" => "Tues", "W" => "Wed", "R" => "Thurs", "F" => "Fri", "S" => "Sat", "U" => "Sun"}

  def format_time(time, ampm=true)
    hour = hour(time)
    mins = minutes(time)
    am = hour < 12
    if hour > 12
      hour = "#{hour - 12}"
    end
    "#{hour}:#{mins.to_s.rjust(2,"0")}#{ampm ? (am ? "am" : "pm") : ""}"
  end

  def pretty_time(ampm=true)
    s = format_time(:start,ampm)
    e = format_time(:end,ampm)
    "#{s}-#{e}"
  end

  def time_and_day
    # days is like "MWF". split into chars, map each one to the longer version, join with /, so Mon/Wed/Fri
    d = days.split("").map {|d| DaysOfWeek[d]}.join("/")
    "#{d} #{pretty_time}"
  end

  def place
    ((building && !building.empty?) ? "#{building} #{room}" : nil)
  end

  def enroll_percent
    no_cap? ? 100 : enroll*100.0/cap
  end

  def time_and_place
    if time_tba?
      "TBA"
    else
      [time_and_day, place].compact.join(", ")
    end
  end
end