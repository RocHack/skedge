class AddEnrollAndMinMaxTimesToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :min_enroll, :integer
    add_column :courses, :min_start_time, :integer
    add_column :courses, :max_start_time, :integer
  end
end
