class FacebookSharedSchedules < ActiveRecord::Migration
  def change
    create_table "user_shares", :id => false do |t|
      t.integer "user_a_id"
      t.integer "user_b_id"
      t.index [:user_a_id, :user_b_id], unique: true
    end
  end
end
