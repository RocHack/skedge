class Section < ActiveRecord::Base
  module Status
    Open = 0
    Closed = 1
    Cancelled = 2
  end

  module Type
    Course = 0
    Lab = 1
    Recitation = 2
    LabLecture = 3
    Workshop = 4
  end

  include Decoratable

  belongs_to :course

  validates :crn, presence: true, uniqueness: true
  validates :course_id, presence: true

  def hour(start_or_end)
    send(:"#{start_or_end}_time").to_s.rjust(4,"0")[0..1].to_i #first two, accounting for 3-digits, ie, "940"
  end

  def minutes(start_or_end)
    send(:"#{start_or_end}_time").to_s[-2..-1].to_i #last 2
  end

  def time_in_hours(start_or_end)
    hour(start_or_end)+minutes(start_or_end)/60.0
  end

  def duration
    time_in_hours(:end) - time_in_hours(:start)
  end

  def cap
    (sec_cap == 999 ? nil : sec_cap) || tot_cap
  end

  def enroll
    [(sec_enroll || 0), (tot_enroll || 0)].max
  end

  def no_cap?
    cap == 0 || cap == nil || cap == 999
  end

  def time_tba?
    days == "TBA"
  end
end

# == Schema Information
#
# Table name: sections
#
#  id           :integer          not null, primary key
#  status       :integer
#  building     :string(255)
#  room         :string(255)
#  days         :string(255)
#  instructors  :string(255)
#  start_time   :integer
#  end_time     :integer
#  sec_enroll   :integer
#  sec_cap      :integer
#  tot_enroll   :integer
#  tot_cap      :integer
#  crn          :integer
#  section_type :integer
#  course_id    :integer
#
