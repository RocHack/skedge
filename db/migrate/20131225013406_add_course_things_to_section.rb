class AddCourseThingsToSection < ActiveRecord::Migration
  def change
    add_column :sections, :course_type, :integer
    add_column :sections, :main_course_id, :integer
    add_column :sections, :term, :integer

    add_column :courses, :short, :string
  end
end
