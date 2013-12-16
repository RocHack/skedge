class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|

      t.timestamps
    end

    create_table "schedules_sections", :id => false do |t|
	  t.column "schedule_id", :integer, :null => false
	  t.column "section_id",  :integer, :null => false
	end
  end
end
