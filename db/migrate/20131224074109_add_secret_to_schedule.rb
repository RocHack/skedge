class AddSecretToSchedule < ActiveRecord::Migration
  def change
    add_column :schedules, :secret, :string
  end
end
