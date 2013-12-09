class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.integer :department_id
      t.integer :num
      t.string :name
      t.text :desc
      t.string :instructors
      t.string :building
      t.string :room
      t.string :days
      t.integer :start_time
      t.integer :end_time
      t.integer :enroll
      t.integer :cap

      t.timestamps
    end
  end
end
