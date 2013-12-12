class AddSisterCourseToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :sister_course_id, :integer
  end
end
