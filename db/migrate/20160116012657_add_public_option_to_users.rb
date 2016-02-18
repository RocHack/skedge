class AddPublicOptionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :public_sharing, :boolean, default: true
  end
end
