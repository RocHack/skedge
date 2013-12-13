class MoveCourseColsToSection < ActiveRecord::Migration    
  def change
    add_column :sections, :building, :string
    add_column :sections, :room, :string
    add_column :sections, :days, :string
    add_column :sections, :instructors, :string

    add_column :sections, :start_time, :integer
    add_column :sections, :end_time, :integer

    add_column :sections, :tot_enroll, :integer
    add_column :sections, :tot_cap, :integer
    add_column :sections, :sec_enroll, :integer
    add_column :sections, :sec_cap, :integer

    add_column :sections, :crn, :integer
    add_column :sections, :status, :integer


    remove_column :courses, :building, :string
    remove_column :courses, :room, :string
    remove_column :courses, :days, :string
    remove_column :courses, :instructors, :string

    remove_column :courses, :start_time, :integer
    remove_column :courses, :end_time, :integer

    remove_column :courses, :tot_enroll, :integer
    remove_column :courses, :tot_cap, :integer
    remove_column :courses, :sec_enroll, :integer
    remove_column :courses, :sec_cap, :integer

    remove_column :courses, :crn, :integer
    remove_column :courses, :status, :integer
  end
end
