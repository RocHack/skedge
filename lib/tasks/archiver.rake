require 'rubygems'
require 'yaml'

#this is to be used for the transition from SQL to mongo & shouldn't really have to be used again

DataFile = "#{Rails.root}/db/archive.yml"

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

task :archive2 => :environment do
	d = User.all.map do |user|
		schedules = user.schedules.map do |schedule|
			sec = schedule.enrollments.map { |s| s["crn"] }
			yr_term = schedule.year
			if schedule.term == Section::Term::Fall
				yr_term += 1
			end
			terms = {Section::Term::Fall => 1,
               Section::Term::Spring => 2,
               Section::Term::Winter => 3,
               Section::Term::Summer => 4}

			yr_term = yr_term.to_s + terms[schedule.term].to_s
			{rid: schedule.rid, yr_term: yr_term.to_i, sections: sec}
		end
		bookmarks = user.bookmarks.map do |b|
			short, num = b["number"].split
			{dept:short, number:num, title:b["title"]}
		end
		{secret:user.secret, schedules:schedules, bookmarks:bookmarks}
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
