require File.join(Rails.root, 'lib/scraper')

task :scrape => [:environment] do
  s = Scraper.new

  case (ENV['scrape_depts'].try(:upcase))
  when nil, 'Y', 'T', 'TRUE', 'YES'
    ##
    # Scrape departments
    #
    begin
      s.scrape_departments
    rescue Exception => e
      puts "*** WARNING: DEPARTMENT SCRAPE FAILED."
    end
  end

  if not Department.any?
    raise '**** no departments, exiting'
  end

  depts = Department.all
  depts = ENV['depts'].split(",").map { |d| Department.find_by_short(d) } if ENV['depts']
  depts = Department.where(school:ENV['school']) if ENV['school']
  yrterm = (ENV['yrterm'] || 20171).to_i

  puts "#{Time.now.to_s}"
  puts "Term: #{yrterm}"

  ##
  # Scrape courses
  #
  depts.each_with_index do |dept, idx|
    puts "#{idx+1}. Scraping #{dept.short}..."
    s.scrape_dept_courses(dept, yrterm)
  end

  s.destroy_sectionless_courses
end