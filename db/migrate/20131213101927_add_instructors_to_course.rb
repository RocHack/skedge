class AddInstructorsToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :instructors, :string
  end
end
