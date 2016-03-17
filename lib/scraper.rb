require 'open-uri'
require 'data_formatter'

class Scraper
  # we use a whitelist for this bc there are some course series with A, B, C, etc
  def courses_with_abc_section
    ["PHY 113", "PHY 114"]
  end

  def create_or_update_section(course)
    s = Section.find_or_initialize_by(crn:course['crn'])
    s.status = DataFormatter::Section.status(course['status'])
    s.instructors = DataFormatter::Section.instructors(course['instructors'])
    s.sec_enroll = course['sectionenrolled'].to_i
    s.sec_cap = course['sectioncap'].to_i
    s.tot_enroll = course['totalenrolled'].to_i
    s.tot_cap = course['totalcap'].to_i
    s.section_type = DataFormatter::Section.type(course['credits'], course['title'])

    # abc match stuff
    s.abc_section = nil
    s.abc_week = nil
    if s.section_type != Section::Type::Course || courses_with_abc_section.include?(course['cn'])
      if s.section_type == Section::Type::Course
        section_match = course['title'].match(/\b(())([A-C])$/i)
      else
        section_match = course['title'].match(/\b(LAB(ORATORY)?|LECTURE)\s+"?'?([A-C])"?'?\b/i)
      end

      if section_match
        s.abc_section = section_match[3]
      end

      if s.section_type != Section::Type::Course
        week_match = course['title'].match(/\bWEEK\s+([A-C])\b/i)
        s.abc_week = week_match[1] if week_match
      end
    end

    # TODO
    # account for courses with different times per day
    if course['schedules']
      schedules = course['schedules']['schedule']
      schedules = [schedules] if schedules.is_a? Hash
      schedules.each do |schedule|
        s.building = schedule['building']
        s.room = schedule['room']
        s.start_time = schedule['start_time'].to_i
        s.end_time = schedule['end_time'].to_i
        s.days = schedule['day']
      end
    else
      s.days = "TBA"
    end

    s
  end

  def create_or_update_course_by(c_fields, course, s)
    dept = c_fields[:department].short
    num = c_fields[:number]

    c = Course.find_or_initialize_by(c_fields)
    c.title = DataFormatter::Course.title(course['title'], course['cn'])
    c.credits = DataFormatter::Course.credits(course['credits'])
    c.description = DataFormatter::Course.encode(course['description']) || c.description
    c.restrictions = DataFormatter::Course.restrictions(course['restrictions']) || c.restrictions
    c.prereqs = course['prerequisites'] || c.prereqs
    c.comments = DataFormatter::Course.comments(dept, num, course['classinfo']) || c.comments
    c.crosslisted = course['crosslisted'] || c.crosslisted
    c.term = DataFormatter::Course.term(course['term'].split[0]) || c.term
    c.year = course['term'].split[1].to_i
    c.yr_term = course['yr_term'].to_i

    # cache some values so we can sort faster
    if !c.min_enroll || s.enroll < c.min_enroll
      c.min_enroll = s.enroll
    end if s.enroll

    if !c.min_start || s.start_time < c.min_start
      c.min_start = s.start_time
    end if s.start_time && s.start_time > 0

    if !c.max_start || s.start_time > c.max_start
      c.max_start = s.start_time
    end if s.start_time && s.start_time > 0

    c
  end

  def scrape_courses(courses, department)
    nonmain_sections = {}
    
    new_sections, new_courses = [], []
    courses.each do |course|
      s = create_or_update_section(course)

      c_fields = {number: course['cn'].match(/\D+(.*)/)[1],
                  department: department,
                  yr_term: course['yr_term'].to_i,
                  title: DataFormatter::Course.title(course['title'], course['cn'])}

      if s.section_type == Section::Type::Course
        c = create_or_update_course_by(c_fields, course, s)
        c.save!

        s.course = c
        s.save!
      else
        #have to save for later in case the course we want isn't created yet
        nonmain_sections[c_fields] ||= []
        nonmain_sections[c_fields] << s
        next
      end
    end

    house_nonmain_sections(nonmain_sections)
  end

  def house_nonmain_sections(nonmain_sections)
    nonmain_sections.each do |c_fields, nonmains|
      c = Course.find_by(c_fields)
      nonmains.each do |nonmain|
        if c
          nonmain.course = c
        else
          # try to find a course that has a different title, but same course num etc:
          possible_courses = Course.where(c_fields.except(:title)).to_a
          if possible_courses.size == 1
            nonmain.course = possible_courses[0]
          elsif possible_courses.any?
            # see if the nonmain title appears in the course title
            title = c_fields[:title].gsub(/-?(\s*)(rec|lab|wkshp)$/i, "").strip
            narrowed_by_title = possible_courses.select do |course|
              course.title.include? title
            end

            if narrowed_by_title.size == 1
              nonmain.course = narrowed_by_title[0]
            else
              # see if the nonmain CRN is mentioned in the course comments
              narrowed_by_crn = possible_courses.select do |course|
                course.comments && course.comments.include?(nonmain.crn.to_s)
              end
              if narrowed_by_crn.size == 1
                nonmain.course = narrowed_by_crn[0]
              else
                # unimplemented case
                puts "SECTION = #{nonmain.inspect}"
                puts "CFIELDS = #{c_fields}"
                puts "MULTIPLE OR NO POSSIBLE COURSES: #{possible_courses.inspect}"
              end
            end
          end

          if nonmain.course
            nonmain.save
          else
            puts "*** orphan nonmain section was not saved: #{nonmain.inspect}"
          end
        end
      end
    end
  end

  def scrape_dept_courses(department, yr_term)
    div = department.school
    dept = department.short
    url = "https://cdcs.ur.rochester.edu/XMLQuery.aspx?id=XML&div=#{div}&dept=#{dept}&term=#{yr_term}"
    
    doc = open(url).read
    hash = Hash.from_xml(doc)

    if !hash
      puts "*** ERROR PARSING XML ***"
      return nil
    end

    if !hash['courses']
      puts "*** No courses found ***"
      return nil
    end

    courses = hash['courses']['course']
    courses = [courses] if courses.is_a? Hash
    scrape_courses(courses, department)
  end

  def destroy_sectionless_courses
    # (probably means there was a title formatting change,
    #  the old course stuck around, but its main section got moved to the new one)
    courses = Course.where.not(id:Section.select(:course_id).distinct.collect(&:course_id))
    puts "Removing #{courses.count} sectionless courses (#{courses.inspect})"
    courses.destroy_all
  end

  def scrape_departments(schools=nil)
    schools ||= [Department::School::ASE,
                 Department::School::Simon,
                 Department::School::Eastman]

    a = Mechanize.new
    a.get('https://cdcs.ur.rochester.edu/') do |page|
      #get the main CDCS form
      form = page.form("form1")
      schools.each do |school|
        new_depts = []
        depts_count = 0

        form.field_with(:name => "ddlSchool").option_with(value: school.to_s).click
        results = form.click_button
        results.form("form1").field_with(:name => "ddlDept").options.each do |dept|
          if dept.value && !dept.value.strip.empty?
            d = Department.create(short:dept.value, name:dept.text.split(" - ", 2).last, school:school)
            depts_count += 1
            if d.valid?
              new_depts << d
            end
          end
        end

        puts "#{Department::FormatSchool[school]}: Found #{depts_count} departments, #{new_depts.count} new (#{new_depts.collect(&:short).join(",")})"
      end
    end
  end
end