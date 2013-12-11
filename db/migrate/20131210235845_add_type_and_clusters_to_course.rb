class AddTypeAndClustersToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :course_type, :integer
    add_column :courses, :status, :integer
    add_column :courses, :clusters, :string
  end
end
