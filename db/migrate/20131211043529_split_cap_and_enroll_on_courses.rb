class SplitCapAndEnrollOnCourses < ActiveRecord::Migration
  def change
  	rename_column :courses, :enroll, :tot_enroll
  	rename_column :courses, :cap, :tot_cap
    add_column :courses, :sec_enroll, :integer
    add_column :courses, :sec_cap, :integer
  end
end
