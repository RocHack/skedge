class InitialSchema < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name
      t.string :short
      
      t.integer :school

      t.index [:short]
    end

    create_table :courses do |t|
      t.string :title
      t.string :number
      
      t.text   :description
      t.text   :restrictions
      t.text   :prereqs
      t.text   :crosslisted
      t.text   :comments

      t.integer :credits
      t.integer :term
      t.integer :year
      t.integer :yr_term

      t.integer :min_enroll
      t.integer :min_start
      t.integer :max_start

      t.belongs_to :department

      t.index [:department_id]
    end

    create_table :sections do |t|
      t.integer :status
      
      t.string :building
      t.string :room
      t.string :days
      t.string :instructors

      t.integer :start_time
      t.integer :end_time
      t.integer :sec_enroll
      t.integer :sec_cap
      t.integer :tot_enroll
      t.integer :tot_cap
      t.integer :crn
      t.integer :section_type

      # for subcourses
      t.string  :abc_section
      t.string  :abc_week
      
      t.belongs_to :course

      t.index [:course_id, :section_type, :crn]
    end

    create_table :instructors do |t|
      t.string :name
    end

    create_table :users do |t|
      t.string :secret
      
      t.integer :last_schedule_id
    end

    create_table :schedules do |t|
      t.string :rid

      t.integer :yr_term
      t.integer :term
      t.integer :year

      t.belongs_to :user

      t.index [:user_id]
    end

    create_table :enrollments do |t|
      t.belongs_to :schedule
      t.belongs_to :section

      t.index [:schedule_id, :section_id]
    end

    create_table :bookmarks do |t|
      t.belongs_to :course
      t.belongs_to :user

      t.index [:course_id, :user_id]
    end
  end
end
