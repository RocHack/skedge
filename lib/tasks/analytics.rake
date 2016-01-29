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

def print(folder, file, name, property=nil, value=nil)
  and_clause = property ? "AND properties->'#{property}' = '#{value}'" : nil
  sql = <<-SQL
  SELECT date_trunc('day', time) AS "day", count(*)
  FROM ahoy_events
  WHERE name = '#{name}' #{and_clause}
  GROUP BY 1
  ORDER BY 1;
  SQL

  analytics_root = File.join(Rails.root, "analytics")

  Dir.mkdir(analytics_root) unless File.directory?(analytics_root)

  dir = File.join(analytics_root, folder)
  file = File.join(dir, file) + ".txt"

  Dir.mkdir(dir) unless File.directory?(dir)
  
  File.open(file, 'w') do |file|
    data(sql).each do |row|
      file.puts "#{row[:time]}\t#{row[:count]}"
    end
  end
end

task :analytics => [:environment] do
  # search
  print(".", "submit", "$submit")


  # add to schedule
  print("scheduling", "add", "$click","add",'true')
  # remove from schedule
  print("scheduling", "remove", "$click","add",'false')
  # re-add to schedule
  print("scheduling", "readd", "$click","readd",'true')


  # click on instructor 
  print("searchbyclick", "instructor", "$click","name",'"instructor"')
  # click on block 
  print("searchbyclick", "block", "$click","name",'"block"')
  # click on prerequisites 
  print("searchbyclick", "prerequisites", "$click","name",'"prerequisites"')
  # click on crosslisted 
  print("searchbyclick", "crosslisted", "$click","name",'"crosslisted"')


  # export gcal
  print("export", "gcal", "$click","name",'"export-ics"')
  # export ics
  print("export", "ics", "$click","name",'"export-gcal"')
  # export image
  print("export", "image", "$click","name",'"export-image"')


  # show subcourses
  print(".", "subcourses", "$click","hide",'false')
end