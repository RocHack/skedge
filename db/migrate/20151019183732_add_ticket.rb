class AddTicket < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.integer :feedback_type
      t.string :email
      t.string :data_info
      t.text :comments
    end
  end
end
