class MoveThingsToSection < ActiveRecord::Migration
  def change
  	remove_column :courses, :sister_course_id, :integer

  	add_column :sections, :year, :integer
  end
end
