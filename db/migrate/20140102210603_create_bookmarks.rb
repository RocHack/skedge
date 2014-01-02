class CreateBookmarks < ActiveRecord::Migration
  def change
    create_table :bookmarks do |t|
      t.integer :course_id
      t.integer :schedule_id

      t.timestamps
    end
  end
end
