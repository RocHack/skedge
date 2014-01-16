class AddAttachmentImageToSchedules < ActiveRecord::Migration
  def self.up
    change_table :schedules do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :schedules, :image
  end
end
