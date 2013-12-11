class Course < ActiveRecord::Base
	validates :crn, uniqueness: true
	belongs_to :department

	module Type
		Course = 0
		Lab = 1
	    Recitation = 2
	    LabLecture = 3
	    Workshop = 4
	    
	    Types = {"LAB" => Lab, "REC" => Recitation, "L/L" => LabLecture, "WRK" => Workshop}
	end

	module Status
		Open = 0
		Closed = 1
		Cancelled = 2

		Statuses = {"Open" => Open, "Closed" => Closed, "Cancelled" => Cancelled}
	end

	def cap
		tot_cap || sec_cap
	end

	def enroll
		tot_enroll || sec_enroll
	end

	def no_cap?
		cap == 0 || cap == nil
	end

	def enroll_percent
		enroll*100.0/cap
	end

	def time_tba?
		days == "TBA"
	end

	def has_prereqs?
		prereqs && prereqs.downcase != "none"
	end

	def formatted_name
		little = %w(and of or the to the a an in but)
		big = %(HIV GPU)
		name.gsub!(/(\w|\.|-|')*/) do |w|
			if little.include?(w.downcase)
				w.downcase
			elsif big.include?(w.upcase)
				w.upcase
			elsif w =~ /^I*([A-D]|V|)$/ || w =~ /^([A-Z]\.)*$/
				w
			else
				w.capitalize
			end
		end
		name[0] = name[0].upcase #in case it starts w little word
		name
	end
end
