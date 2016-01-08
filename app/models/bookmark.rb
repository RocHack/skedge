class Bookmark < ActiveRecord::Base
  validates_presence_of :course_id, :user_id

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
