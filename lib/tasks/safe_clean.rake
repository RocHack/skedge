MARKER = 999900000

namespace :enrollments do
  task :protect => [:environment] do
    Enrollment.transaction do
      Enrollment.all.each do |e|
        raise "Trying to protected already protected enrollment #{e.inspect}" if e.section_id > MARKER
        e.section_id = MARKER + e.section.crn
        e.save
      end
    end
  end

  task :restore => [:environment] do
    Enrollment.transaction do
      Enrollment.all.each do |e|
        raise "Trying to restore unprotected enrollment #{e.inspect}" if e.section_id < MARKER
        s = Section.find_by(crn:e.section_id - MARKER)
        raise "Trying to restore enrollment to nonexistent CRN: #{e.section_id - MARKER}" if !s
        e.section_id = s.id
        e.save
      end
    end
  end
end

task :safe_clean => [:environment] do
  Enrollment.all.each do |e|
    raise "Enrollments have not been protected. Run `rake enrollments:protect` first." if e.section_id < MARKER
  end

  Course.destroy_all
  Section.destroy_all
end