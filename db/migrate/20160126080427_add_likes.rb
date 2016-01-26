class AddLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.belongs_to :course
      t.belongs_to :user

      t.index [:course_id, :user_id]
    end
  end
end
