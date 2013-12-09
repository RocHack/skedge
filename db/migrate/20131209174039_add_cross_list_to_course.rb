class AddCrossListToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :cross_listed, :string
  end
end
