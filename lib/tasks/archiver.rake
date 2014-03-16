require 'rubygems'
require 'yaml'

#this is to be used for the transition from SQL to mongo & shouldn't really have to be used again

DataFile = "#{Rails.root}/db/old_data.yml"

task :archive => :environment do
	d = Schedule.all.map do |schedule|
		sec = schedule.sections.map do |s|
			s.crn
		end
		bookmarks = schedule.bookmarks.map do |b|
			{dept:b.course.short, number:b.course.num, title:b.course.name, term:b.course.term, year:b.course.year}
		end
		{secret:schedule.secret, rid:schedule.rid.to_i, bookmarks:bookmarks, sections:sec}
	end

	File.open(DataFile, 'w') do |out|
		YAML.dump(d, out)
	end
end

def search_for_section(crn, thing)
	begin
		Course.find_by("#{thing}.crn" => crn).send(:"#{thing}").find_by(crn:crn)
	rescue
		nil
	end
end

task :unarchive => :environment do
	data = YAML.load_file(DataFile)
	data.each do |old_sk|
		u = User.create(secret:old_sk[:secret])
		new_sk = Schedule.new(year:2014, term:1, rid:old_sk[:rid])

		old_sk[:sections].each do |crn|
			s = nil
			s ||= search_for_section(crn, "sections")
			s ||= search_for_section(crn, "labs")
			s ||= search_for_section(crn, "recitations")
			s ||= search_for_section(crn, "lab_lectures")
			s ||= search_for_section(crn, "workshops")

			raise "couldn't find crn #{crn}" if !s

			new_sk.enrollments << s.data
		end
		
		old_sk[:bookmarks].each do |bk|
			c = Course.find_by(bk)
			u.bookmarks << {title:c.title, id:c.id.to_s, number:"#{bk[:dept]} #{bk[:number]}"}
		end

		u.schedules << new_sk
		u.save
	end
end
