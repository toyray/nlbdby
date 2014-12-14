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

ActiveRecord::Schema.define(version: 20141214143024) do

  create_table "book_user_meta", force: true do |t|
    t.integer  "book_id"
    t.integer  "rating",     default: 2
    t.boolean  "borrowed",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "book_user_meta", ["book_id"], name: "index_book_user_meta_on_book_id", using: :btree

  create_table "books", force: true do |t|
    t.string   "brn"
    t.string   "title"
    t.string   "author"
    t.integer  "pages"
    t.integer  "height"
    t.string   "call_no"
    t.string   "section"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "library_count",   default: 0,           null: false
    t.integer  "available_count", default: 0,           null: false
    t.string   "status",          default: "completed"
    t.datetime "last_updated_at"
  end

  add_index "books", ["brn"], name: "index_books_on_brn", unique: true, using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "libraries", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "libraries", ["name"], name: "index_libraries_on_name", unique: true, using: :btree

  create_table "library_books", force: true do |t|
    t.integer  "library_id"
    t.integer  "book_id"
    t.boolean  "available",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "singapore",  default: false
    t.boolean  "reference",  default: false
  end

  add_index "library_books", ["book_id"], name: "index_library_books_on_book_id", using: :btree
  add_index "library_books", ["library_id"], name: "index_library_books_on_library_id", using: :btree

end
