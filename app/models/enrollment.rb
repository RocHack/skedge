class Enrollment < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :section

  validates :schedule_id, :section_id, presence: true
end

# == Schema Information
#
# Table name: enrollments
#
#  id          :integer          not null, primary key
#  schedule_id :integer
#  section_id  :integer
#
