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
    collection.each_with_index do |x, idx|
      row = yield x, idx
      file.puts(row.join("\t"))
    end
  end
end

def print_basic(folder, file, name, property=nil, value=nil)
  and_clause = property ? "AND properties->'#{property}' = '#{value.inspect}'" : nil
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
    print_basic("export", "image", "$click", "name", "export-image")

    print_basic(".", "subcourses", "$click", "hide", false)
  end

  task :per_person => [:environment] do
    # number of re-adds/conflicts = playing around with the schedule
    # search diversity over time

    # 1) A) avg number of seaches/clicks between adds
    #    B) % browsing vs % direct search
    #       - mark whether each add for a class was browsed or searched
    #       - then per person, see % of classes browsed or searched

    data = []
    nav_names = ["crosslist", "instructor", "prereqs"]
    User.all.each do |u|
      query = <<-SQL
        select * from ahoy_events
        where user_id = '#{u.id}' and (name = '$submit' or name = '$click')
        order by time;
      SQL

      navs = 0
      current_visit = nil
      ActiveRecord::Base.connection.execute(query).each do |result|
        if current_visit && result["visit_id"] != current_visit
          navs = 0
        end
        current_visit = result["visit_id"]
  
        properties = JSON.parse(result["properties"])

        if result["name"] == "$submit" ||
           result["name"] == "$click" && nav_names.include?(properties["name"])
          navs += 1
        end

        if result["name"] == "$click" && properties["add"]
          data[navs] = data[navs].to_i + 1
          navs = 0
        end
      end
    end

    print("per_person", ".", "clicks2add", data) do |x, idx|
      [idx, x || 0]
    end
  end

  task :search_type => [:environment] do
    # percentage of search types
    # percentage of searches that come up empty
  end
end

task :analytics => ["analytics:basic", "analytics:per_person"]
