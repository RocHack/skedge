class Bookmark < ActiveRecord::Base
  validates :course_id, :user_id, presence: true
  validates :course_id, uniqueness: {scope: :user_id}

  belongs_to :user
  belongs_to :course
end

# == Schema Information
#
# Table name: bookmarks
#
#  id        :integer          not null, primary key
#  course_id :integer
#  user_id   :integer
#
