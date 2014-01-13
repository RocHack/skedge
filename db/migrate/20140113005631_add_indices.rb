class AddIndices < ActiveRecord::Migration
  def change
	add_index :courses, :num
	add_index :courses, :short
	add_index :courses, :name
	add_index :courses, :year
	add_index :courses, :term
	add_index :courses, :course_type
	add_index :courses, :main_course_id
	add_index :courses, :sister_course_id

	add_index :departments, :short
	
	add_index :sections, :course_id
	add_index :sections, :start_time
	add_index :sections, :main_course_id
	add_index :sections, :days

	add_index :enrollments, :schedule_id
	add_index :enrollments, :section_id

	add_index :bookmarks, :schedule_id
	add_index :bookmarks, :course_id
  end
end
