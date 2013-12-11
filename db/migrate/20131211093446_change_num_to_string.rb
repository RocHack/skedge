class ChangeNumToString < ActiveRecord::Migration
  def up
  	change_column :courses, :num, :string
  end

  def down
  	change_column :courses, :num, :integer
  end
end
