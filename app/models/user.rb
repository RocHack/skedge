require 'securerandom'

class User < ActiveRecord::Base
  validates :secret, uniqueness: true, presence: true
  
  has_many :schedules, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_courses, through: :bookmarks, source: :course

  belongs_to :last_schedule, class_name: "Schedule"

  has_and_belongs_to_many :share_users_forward,
    join_table: "user_shares",
    foreign_key: "user_a_id",
    association_foreign_key: "user_b_id",
    class_name: :User

  has_and_belongs_to_many :share_users_reverse,
    join_table: "user_shares",
    foreign_key: "user_b_id",
    association_foreign_key: "user_a_id",
    class_name: :User

  has_many :share_requests,
    foreign_key: "user_b_id"

  has_many :sent_share_requests,
    foreign_key: "user_a_id",
    class_name: :ShareRequest

  def share_users
    share_users_forward + share_users_reverse
  end

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
