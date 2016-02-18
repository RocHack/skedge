class ShareRequest < ActiveRecord::Base
  belongs_to :user_a, class_name: :User
  belongs_to :user_b, class_name: :User

  validates :user_a_id, uniqueness: { scope: [:user_b_id] }
  validates :user_b_id, uniqueness: { scope: [:user_a_id] }
end