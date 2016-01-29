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

def print_basic(folder, file, name, property=nil, value=nil)
  and_clause = property ? "AND properties->'#{property}' = '#{value.inspect}'" : nil
  sql = <<-SQL
  SELECT date_trunc('day', time) AS "day", count(*)
  FROM ahoy_events
  WHERE name = '#{name}' #{and_clause}
  GROUP BY 1
  ORDER BY 1;
  SQL

  analytics_root = File.join(Rails.root, "analytics")
  Dir.mkdir(analytics_root) unless File.directory?(analytics_root)

  dir = File.join(analytics_root, "basic")
  Dir.mkdir(dir) unless File.directory?(dir)

  dir = File.join(dir, folder)
  Dir.mkdir(dir) unless File.directory?(dir)

  file = File.join(dir, file) + ".txt"
  
  File.open(file, 'w') do |file|
    data(sql).each do |row|
      file.puts "#{row[:time]}\t#{row[:count]}"
    end
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
end

task :analytics => ["analytics:basic"]
