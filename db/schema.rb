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

ActiveRecord::Schema.define(version: 20160115062542) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ahoy_events", id: :uuid, force: :cascade do |t|
    t.uuid     "visit_id"
    t.integer  "user_id"
    t.string   "name"
    t.jsonb    "properties"
    t.datetime "time"
  end

  add_index "ahoy_events", ["time"], name: "index_ahoy_events_on_time", using: :btree
  add_index "ahoy_events", ["user_id"], name: "index_ahoy_events_on_user_id", using: :btree
  add_index "ahoy_events", ["visit_id"], name: "index_ahoy_events_on_visit_id", using: :btree

  create_table "bookmarks", force: :cascade do |t|
    t.integer "course_id"
    t.integer "user_id"
  end

  add_index "bookmarks", ["course_id", "user_id"], name: "index_bookmarks_on_course_id_and_user_id", using: :btree

  create_table "courses", force: :cascade do |t|
    t.string  "title"
    t.string  "number"
    t.text    "description"
    t.text    "restrictions"
    t.text    "prereqs"
    t.text    "crosslisted"
    t.text    "comments"
    t.string  "credits"
    t.integer "term"
    t.integer "year"
    t.integer "yr_term"
    t.integer "min_enroll"
    t.integer "min_start"
    t.integer "max_start"
    t.integer "department_id"
  end

  add_index "courses", ["department_id"], name: "index_courses_on_department_id", using: :btree

  create_table "departments", force: :cascade do |t|
    t.string  "name"
    t.string  "short"
    t.integer "school"
  end

  add_index "departments", ["short"], name: "index_departments_on_short", using: :btree

  create_table "enrollments", force: :cascade do |t|
    t.integer "schedule_id"
    t.integer "section_id"
  end

  add_index "enrollments", ["schedule_id", "section_id"], name: "index_enrollments_on_schedule_id_and_section_id", using: :btree

  create_table "instructors", force: :cascade do |t|
    t.string "name"
  end

  create_table "schedules", force: :cascade do |t|
    t.string  "rid"
    t.integer "yr_term"
    t.integer "term"
    t.integer "year"
    t.integer "user_id"
  end

  add_index "schedules", ["user_id"], name: "index_schedules_on_user_id", using: :btree

  create_table "sections", force: :cascade do |t|
    t.integer "status"
    t.string  "building"
    t.string  "room"
    t.string  "days"
    t.string  "instructors"
    t.integer "start_time"
    t.integer "end_time"
    t.integer "sec_enroll"
    t.integer "sec_cap"
    t.integer "tot_enroll"
    t.integer "tot_cap"
    t.integer "crn"
    t.integer "section_type"
    t.string  "abc_section"
    t.string  "abc_week"
    t.integer "course_id"
  end

  add_index "sections", ["course_id", "section_type", "crn"], name: "index_sections_on_course_id_and_section_type_and_crn", using: :btree

  create_table "tickets", force: :cascade do |t|
    t.integer "feedback_type"
    t.string  "email"
    t.string  "data_info"
    t.text    "comments"
  end

  create_table "user_shares", id: false, force: :cascade do |t|
    t.integer "user_a_id"
    t.integer "user_b_id"
  end

  add_index "user_shares", ["user_a_id", "user_b_id"], name: "index_user_shares_on_user_a_id_and_user_b_id", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string  "secret"
    t.integer "last_schedule_id"
  end

  create_table "visits", id: :uuid, force: :cascade do |t|
    t.uuid     "visitor_id"
    t.string   "ip"
    t.text     "user_agent"
    t.text     "referrer"
    t.text     "landing_page"
    t.integer  "user_id"
    t.string   "referring_domain"
    t.string   "search_keyword"
    t.string   "browser"
    t.string   "os"
    t.string   "device_type"
    t.integer  "screen_height"
    t.integer  "screen_width"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.string   "postal_code"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "utm_campaign"
    t.datetime "started_at"
  end

  add_index "visits", ["user_id"], name: "index_visits_on_user_id", using: :btree

end
