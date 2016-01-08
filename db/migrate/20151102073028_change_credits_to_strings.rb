class ChangeCreditsToStrings < ActiveRecord::Migration
  def self.up
    change_column :courses, :credits, :string
  end
 
  def self.down
    change_column :courses, :credits, :integer
  end
end
