class AddPublicOptionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :public_sharing, :boolean, default: false
  end
end
