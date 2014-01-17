class AddRidToSchedules < ActiveRecord::Migration
  def up
    add_column :schedules, :rid, :string

    Schedule.all.each do |s|
    	s.rid = Schedule.make_rid
    	s.save
    end
  end

  def down
    remove_column :schedules, :rid
  end
end
