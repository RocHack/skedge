class Enrollment < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :section

  validates_presence_of :schedule_id, :section_id
end

# == Schema Information
#
# Table name: enrollments
#
#  id          :integer          not null, primary key
#  schedule_id :integer
#  section_id  :integer
#
