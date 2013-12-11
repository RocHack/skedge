class ChangeTermToInteger < ActiveRecord::Migration
  def up
  	change_column :courses, :term, :integer
  end

  def down
  	change_column :courses, :term, :string
  end
end
