class AddFbidToUser < ActiveRecord::Migration
  def change
    add_column :users, :fb_id, :string
  end
end
