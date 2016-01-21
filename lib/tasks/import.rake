require 'rubygems'
require 'yaml'

#this is to be used for the transition from old skedge to skedge2 & shouldn't really have to be used again

DataFile = "#{Rails.root}/db/archive.yml"

task :unarchive_no_bookmarks => :environment do
  data = YAML.load_file(DataFile)
  data.each do |user|
    u = User.find_or_create_by(secret: user[:secret])
    u.save
    user[:schedules].each do |schedule|
      if schedule[:sections].any?
        year, term = Course.yr_term_to_year_and_term(schedule[:yr_term])

        s = Schedule.find_or_initialize_by(rid: schedule[:rid].to_s)
        s.user = u
        s.yr_term = schedule[:yr_term]
        s.year = year
        s.term = term
        s.enrollments.destroy_all
        s.save

        schedule[:sections].each do |crn|
          section = Section.find_by(crn: crn)
          if !section
            puts "couldn't find section #{crn} in schedule #{schedule[:rid]}"
            next
          end
          Enrollment.create(section:section, schedule:s)
        end
      end
    end
    u.last_schedule = u.schedules.sort_by(&:yr_term).last
    u.save
  end
end

task :unarchive_bookmarks => :environment do
  data = YAML.load_file(DataFile)
  data.each do |user|
    u = User.find_by(secret: user[:secret])
    user[:bookmarks].each do |bookmark|
      d = Department.find_by(short: bookmark[:dept])
      c = Course.find_by(department:d, number:bookmark[:number], title:bookmark[:title])

      if c
        u.bookmarked_courses << c
      else
        puts "Couldn't find course #{bookmark[:dept]} #{bookmark[:number]}: #{bookmark[:title]}"
      end
    end
    u.save
  end
end