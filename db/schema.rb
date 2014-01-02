# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131230045600) do

  create_table "courses", force: true do |t|
    t.integer  "department_id"
    t.string   "num"
    t.string   "name"
    t.text     "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "prereqs"
    t.integer  "credits"
    t.string   "comments"
    t.string   "restrictions"
    t.string   "cross_listed"
    t.integer  "year"
    t.integer  "term"
    t.integer  "course_type"
    t.string   "clusters"
    t.integer  "main_course_id"
    t.integer  "sister_course_id"
    t.string   "instructors"
    t.integer  "min_enroll"
    t.integer  "min_start_time"
    t.integer  "max_start_time"
    t.string   "short"
  end

  create_table "departments", force: true do |t|
    t.string   "name"
    t.string   "short"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "enrollments", force: true do |t|
    t.integer  "schedule_id"
    t.integer  "section_id"
    t.integer  "color"
    t.integer  "special"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schedules", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "secret"
  end

  create_table "schedules_sections", id: false, force: true do |t|
    t.integer "schedule_id", null: false
    t.integer "section_id",  null: false
  end

  create_table "sections", force: true do |t|
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "building"
    t.string   "room"
    t.string   "days"
    t.string   "instructors"
    t.integer  "start_time"
    t.integer  "end_time"
    t.integer  "tot_enroll"
    t.integer  "tot_cap"
    t.integer  "sec_enroll"
    t.integer  "sec_cap"
    t.integer  "crn"
    t.integer  "status"
    t.integer  "course_type"
    t.integer  "main_course_id"
    t.integer  "term"
  end

  create_table "tickets", force: true do |t|
    t.string   "email"
    t.string   "contents"
    t.integer  "read"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
