class Instructor < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :courses
end

# == Schema Information
#
# Table name: instructors
#
#  id   :integer          not null, primary key
#  name :string(255)
#
