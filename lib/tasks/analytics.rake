require 'json'

def data(query)
  data = []
  ActiveRecord::Base.connection.execute(query).each do |result| 
    current = Date.parse(result['day'])
    if data.any?
      last = data.last[:time]
      diff = current - last
      if diff > 1
        (diff - 1).to_i.times do |i|
          data << {time: last+(i+1), count: 0 }
        end
      end
    end
    data << { time: current, count: result['count'].to_i }
  end
  data
end

def print(outer, inner, file, collection)
  analytics_root = File.join(Rails.root, "analytics")
  Dir.mkdir(analytics_root) unless File.directory?(analytics_root)

  dir = File.join(analytics_root, outer)
  Dir.mkdir(dir) unless File.directory?(dir)

  dir = File.join(dir, inner)
  Dir.mkdir(dir) unless File.directory?(dir)

  file = File.join(dir, file) + ".txt"
  
  File.open(file, 'w') do |file|
    collection.each_with_index do |a, b|
      row = block_given? ? (yield a, b) : a
      file.puts(row.join("\t"))
    end
  end
end

def print_basic(folder, file, name, property=nil, value=nil)
  value = [value] if not value.is_a? Array
  or_clauses = value.map do |val|
    "properties->'#{property}' = '#{val.inspect}'"
  end.join(" OR ")
  and_clause = property ? "AND (#{or_clauses})" : nil
  sql = <<-SQL
  SELECT date_trunc('day', time) AS "day", count(*)
  FROM ahoy_events
  WHERE name = '#{name}' #{and_clause}
  GROUP BY 1
  ORDER BY 1;
  SQL

  print("basic", folder, file, data(sql)) do |row|
    [row[:time], row[:count]]
  end
end

def count_search_types_in_query(types=Hash.new(0), query)
  q = Course.text_to_query(query)

  types[:description] += 1   if q.attrs[:description]
  types[:credits] += 1       if q.attrs[:credits] != { :> => "0" }
  types[:department_id] += 1 if q.attrs[:department_id]
  types[:crosslisted] += 1   if q.attrs[:crosslisted]
  types[:crn] += 1           if q.attrs[:sections].try(:[], :crn)
  types[:year] += 1          if q.attrs[:year]
  types[:number] += 1        if q.attrs[:number]
  types[:instructor] += 1    if q.attrs[:sections].try(:[], :instructors)
  types[:term] += 1          if q.attrs[:term]
  types[:random] += 1        if q.orders == ["RANDOM()"]
  types[:w] += 1             if q.attrs[:number].try(:end_with?, "W%")
  types[:title] += 1         if q.attrs[:title]

  types
end

namespace :analytics do
  task :basic => [:environment] do
    print_basic(".", "submit", "$submit") # search

    print_basic("scheduling", "add", "$click", "add", true)
    print_basic("scheduling", "remove", "$click", "add", false)
    print_basic("scheduling", "readd", "$click", "readd", true)

    print_basic("searchbyclick", "instructor", "$click", "name", "instructor")
    print_basic("searchbyclick", "block", "$click", "name", "block")
    print_basic("searchbyclick", "prerequisites", "$click", "name", "prerequisites")
    print_basic("searchbyclick", "crosslisted", "$click", "name", "crosslisted")

    print_basic("export", "gcal", "$click", "name", "export-ics")
    print_basic("export", "ics", "$click", "name", "export-gcal")
    print_basic("export", "image", "$click", "name", ["export-image-jpg", "export-image-png"])

    print_basic(".", "subcourses", "$click", "hide", false)
  end

  task :per_person => [:environment] do
    # number of re-adds/conflicts = playing around with the schedule

    # 1) A) avg number of seaches/clicks between adds
    #    B) % browsing vs % direct search
    #       - mark whether each add for a class was browsed or searched
    #       - then per person, see % of classes browsed or searched

    clicks2add = {}
    nav_names = ["crosslist", "instructor", "prereqs"]
    num_types_of_search_dt = {}

    User.all.each do |u|
      query = <<-SQL
        select * from ahoy_events
        where user_id = '#{u.id}' and (name = '$submit' or name = '$click')
        order by time;
      SQL

      clicks2add[u.id] = []
      num_types_of_search_dt[u.id] = []

      navs = 0
      current_visit = nil

      ActiveRecord::Base.connection.execute(query).each do |result|
        if current_visit && result["visit_id"] != current_visit
          navs = 0
        end
        current_visit = result["visit_id"]
  
        properties = JSON.parse(result["properties"])

        # compute number of navigations between adds
        if result["name"] == "$submit" ||
           result["name"] == "$click" && nav_names.include?(properties["name"])
          navs += 1
        end

        if result["name"] == "$click" && properties["add"]
          clicks2add[u.id][navs] = clicks2add[u.id][navs].to_i + 1
          navs = 0
        end

        # compute diversity of search type over time per user
        if result["name"] == "$submit"
          types = count_search_types_in_query(properties["q"])
          types.delete :department_id
          types.delete :number
          num_types_of_search_dt[u.id] << types.length
        end
      end
    end

    print("per_person", ".", "clicks2add", clicks2add) do |x, idx|
      user, values = x
      [user, *values]
    end

    print("per_person", ".", "search_types", num_types_of_search_dt) do |x, idx|
      user, values_dt = x
      [user, *values_dt]
    end
  end

  task :search => [:environment] do
    query = <<-SQL
      select * from ahoy_events
      where name = '$submit';
    SQL

    empty = 0
    total = 0

    types = Hash.new(0)

    ActiveRecord::Base.connection.execute(query).each do |result|
      properties = JSON.parse(result["properties"])

      begin
        q = Course.sk_query(properties["q"])
        if (q.empty?)
          empty += 1
        end
        total += 1
      rescue Exception => e
      end

      count_search_types_in_query(types, properties["q"])
    end

    # percentage of searches that come up empty
    print("search", ".", "empty", {empty:empty, total:total})

    # percentage of search types
    print("search", ".", "types", types)
  end
end

task :analytics => ["analytics:basic", "analytics:per_person", "analytics:search"]
