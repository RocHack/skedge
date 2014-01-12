class CreateEnrollments < ActiveRecord::Migration
  def up
    create_table :enrollments do |t|
      t.integer :schedule_id
      t.integer :section_id
      t.integer :color
      t.integer :special

      t.timestamps
    end

    drop_table "schedules_sections"
  end

  def down
    drop_table :enrollments

    create_table "schedules_sections", :id => false do |t|
  	  t.column "schedule_id", :integer, :null => false
  	  t.column "section_id",  :integer, :null => false
  	end
  end
end
