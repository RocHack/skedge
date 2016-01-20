require 'securerandom'

class User < ActiveRecord::Base
  validates :secret, uniqueness: true, presence: true
  
  has_many :schedules, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_courses, through: :bookmarks, source: :course

  belongs_to :last_schedule, class_name: "Schedule"

  before_validation(on: :create) do
    self.secret ||= SecureRandom.hex
  end
end

# == Schema Information
#
# Table name: users
#
#  id               :integer          not null, primary key
#  secret           :string(255)
#  last_schedule_id :integer
#
