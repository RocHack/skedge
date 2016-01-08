class Department < ActiveRecord::Base
  module School
    ASE = 1
    Simon = 2
    Eastman = 6
  end

  FormatSchool = {1 => "Arts, Sciences, and Engineering", 2 => "Simon", 6 => "Eastman"}

  has_many :courses

  validates :short, :name, presence: true, uniqueness: true


  def self.find_by_short(short)
    short.upcase!
    # Some special cases
    short = "MTH" if short == "MATH"
    short = "CSC" if short == "CS"
    Department.find_by(short: short)
  end
end

# == Schema Information
#
# Table name: departments
#
#  id     :integer          not null, primary key
#  name   :string(255)
#  short  :string(255)
#  school :integer
#
