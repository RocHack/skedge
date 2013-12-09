class AddDetailsToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :prereqs, :string
    add_column :courses, :credits, :integer
    add_column :courses, :comments, :string
    add_column :courses, :crn, :integer
    add_column :courses, :restrictions, :string
  end
end
