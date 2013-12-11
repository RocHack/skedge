class AddMainCourseIdToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :main_course_id, :integer
  end
end
