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

ActiveRecord::Schema.define(version: 20131211214354) do

  create_table "courses", force: true do |t|
    t.integer  "department_id"
    t.string   "num"
    t.string   "name"
    t.text     "desc"
    t.string   "instructors"
    t.string   "building"
    t.string   "room"
    t.string   "days"
    t.integer  "start_time"
    t.integer  "end_time"
    t.integer  "tot_enroll"
    t.integer  "tot_cap"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "prereqs"
    t.integer  "credits"
    t.string   "comments"
    t.integer  "crn"
    t.string   "restrictions"
    t.string   "cross_listed"
    t.integer  "year"
    t.integer  "term",           limit: 255
    t.integer  "course_type"
    t.integer  "status"
    t.string   "clusters"
    t.integer  "sec_enroll"
    t.integer  "sec_cap"
    t.integer  "main_course_id"
  end

  create_table "departments", force: true do |t|
    t.string   "name"
    t.string   "short"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
