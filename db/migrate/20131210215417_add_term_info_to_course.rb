class AddTermInfoToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :year, :integer
    add_column :courses, :term, :integer
  end
end
