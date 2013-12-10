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

ActiveRecord::Schema.define(version: 20131210215417) do

  create_table "courses", force: true do |t|
    t.integer  "department_id"
    t.integer  "num"
    t.string   "name"
    t.text     "desc"
    t.string   "instructors"
    t.string   "building"
    t.string   "room"
    t.string   "days"
    t.integer  "start_time"
    t.integer  "end_time"
    t.integer  "enroll"
    t.integer  "cap"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "prereqs"
    t.integer  "credits"
    t.string   "comments"
    t.integer  "crn"
    t.string   "restrictions"
    t.string   "cross_listed"
    t.integer  "year"
    t.string   "term"
  end

  create_table "departments", force: true do |t|
    t.string   "name"
    t.string   "short"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
