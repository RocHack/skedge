class MainController < ApplicationController
  def index
    @departments = Department.all.group_by do |dept|
      Department::FormatSchool[dept.school]
    end
  end
end