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

ActiveRecord::Schema.define(version: 20140308035504) do

  create_table "bookmarks", force: true do |t|
    t.integer  "course_id"
    t.integer  "schedule_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bookmarks", ["course_id"], name: "index_bookmarks_on_course_id"
  add_index "bookmarks", ["schedule_id"], name: "index_bookmarks_on_schedule_id"

  create_table "courses", force: true do |t|
    t.integer  "department_id"
    t.string   "num"
    t.string   "name"
    t.text     "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "credits"
    t.string   "restrictions"
    t.integer  "course_type"
    t.integer  "main_course_id"
    t.string   "instructors"
    t.integer  "min_enroll"
    t.integer  "min_start_time"
    t.integer  "max_start_time"
    t.string   "short"
    t.text     "clusters"
    t.text     "prereqs"
    t.text     "cross_listed"
    t.text     "comments"
    t.integer  "year"
    t.integer  "term"
  end

  add_index "courses", ["course_type"], name: "index_courses_on_course_type"
  add_index "courses", ["main_course_id"], name: "index_courses_on_main_course_id"
  add_index "courses", ["name"], name: "index_courses_on_name"
  add_index "courses", ["num"], name: "index_courses_on_num"
  add_index "courses", ["short"], name: "index_courses_on_short"

  create_table "departments", force: true do |t|
    t.string   "name"
    t.string   "short"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "departments", ["short"], name: "index_departments_on_short"

  create_table "enrollments", force: true do |t|
    t.integer  "schedule_id"
    t.integer  "section_id"
    t.integer  "color"
    t.integer  "special"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "enrollments", ["schedule_id"], name: "index_enrollments_on_schedule_id"
  add_index "enrollments", ["section_id"], name: "index_enrollments_on_section_id"

  create_table "schedules", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "secret"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "rid"
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
    t.integer  "year"
  end

  add_index "sections", ["course_id"], name: "index_sections_on_course_id"
  add_index "sections", ["days"], name: "index_sections_on_days"
  add_index "sections", ["main_course_id"], name: "index_sections_on_main_course_id"
  add_index "sections", ["start_time"], name: "index_sections_on_start_time"

  create_table "tickets", force: true do |t|
    t.string   "email"
    t.integer  "read"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "contents"
  end

end
