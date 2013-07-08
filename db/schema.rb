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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130708130150) do

  create_table "assessments", :force => true do |t|
    t.text     "using_materials"
    t.string   "involvement"
    t.integer  "staff_experience"
    t.integer  "staff_availability"
    t.integer  "space"
    t.integer  "request_course"
    t.integer  "request_materials"
    t.integer  "catalogs"
    t.integer  "digital_collections"
    t.string   "involve_again"
    t.text     "not_involve_again"
    t.text     "better_future"
    t.integer  "course_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.text     "comments"
  end

  add_index "assessments", ["better_future"], :name => "index_assessments_on_better_future"
  add_index "assessments", ["catalogs"], :name => "index_assessments_on_catalogs"
  add_index "assessments", ["digital_collections"], :name => "index_assessments_on_digital_collections"
  add_index "assessments", ["involve_again"], :name => "index_assessments_on_involve_again"
  add_index "assessments", ["involvement"], :name => "index_assessments_on_involvement"
  add_index "assessments", ["not_involve_again"], :name => "index_assessments_on_not_involve_again"
  add_index "assessments", ["request_course"], :name => "index_assessments_on_request_course"
  add_index "assessments", ["request_materials"], :name => "index_assessments_on_request_materials"
  add_index "assessments", ["space"], :name => "index_assessments_on_space"
  add_index "assessments", ["staff_availability"], :name => "index_assessments_on_staff_availability"
  add_index "assessments", ["staff_experience"], :name => "index_assessments_on_staff_experience"
  add_index "assessments", ["using_materials"], :name => "index_assessments_on_using_materials"

  create_table "courses", :force => true do |t|
    t.string   "title"
    t.string   "subject"
    t.string   "course_number"
    t.string   "affiliation"
    t.string   "contact_email",           :limit => 150, :null => false
    t.string   "contact_phone",           :limit => 25,  :null => false
    t.datetime "pre_class_appt"
    t.datetime "timeframe"
    t.datetime "time_choice_1"
    t.datetime "time_choice_2"
    t.datetime "time_choice_3"
    t.integer  "repository_id"
    t.integer  "room_id"
    t.text     "staff_involvement"
    t.integer  "number_of_students"
    t.string   "status"
    t.string   "file"
    t.string   "external_syllabus"
    t.string   "duration"
    t.text     "comments"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "course_sessions"
    t.string   "session_count"
    t.text     "goal"
    t.string   "instruction_session"
    t.datetime "time_choice_4"
    t.datetime "pre_class_appt_choice_1"
    t.datetime "pre_class_appt_choice_2"
    t.datetime "pre_class_appt_choice_3"
    t.string   "contact_first_name",      :limit => 100
    t.string   "contact_last_name",       :limit => 100
    t.string   "contact_username",        :limit => 100
  end

  add_index "courses", ["affiliation"], :name => "index_courses_on_affiliation"
  add_index "courses", ["comments"], :name => "index_courses_on_comments"
  add_index "courses", ["contact_email"], :name => "index_courses_on_contact_email"
  add_index "courses", ["contact_phone"], :name => "index_courses_on_contact_phone"
  add_index "courses", ["course_number"], :name => "index_courses_on_course_number"
  add_index "courses", ["duration"], :name => "index_courses_on_duration"
  add_index "courses", ["external_syllabus"], :name => "index_courses_on_external_syllabus"
  add_index "courses", ["pre_class_appt"], :name => "index_courses_on_pre_class_appt"
  add_index "courses", ["staff_involvement"], :name => "index_courses_on_staff_involvement"
  add_index "courses", ["status"], :name => "index_courses_on_status"
  add_index "courses", ["subject"], :name => "index_courses_on_subject"
  add_index "courses", ["timeframe"], :name => "index_courses_on_timeframe"
  add_index "courses", ["title"], :name => "index_courses_on_title"

  create_table "courses_item_attributes", :id => false, :force => true do |t|
    t.integer "item_attribute_id"
    t.integer "course_id"
  end

  create_table "courses_staff_involvements", :id => false, :force => true do |t|
    t.integer "staff_involvement_id"
    t.integer "course_id"
  end

  create_table "courses_users", :id => false, :force => true do |t|
    t.integer "course_id"
    t.integer "user_id"
  end

  create_table "emails", :force => true do |t|
    t.string   "to"
    t.string   "bcc"
    t.string   "from"
    t.string   "reply_to"
    t.string   "subject"
    t.text     "body"
    t.date     "date_sent"
    t.boolean  "message_sent", :default => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "item_attributes", :force => true do |t|
    t.string   "name",        :null => false
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "item_attributes", ["description"], :name => "index_item_attributes_on_description"
  add_index "item_attributes", ["name"], :name => "index_item_attributes_on_name"

  create_table "item_attributes_repositories", :id => false, :force => true do |t|
    t.integer "item_attribute_id"
    t.integer "repository_id"
  end

  create_table "item_attributes_rooms", :id => false, :force => true do |t|
    t.integer "item_attribute_id"
    t.integer "room_id"
  end

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "locations", ["name"], :name => "index_locations_on_name"

  create_table "notes", :force => true do |t|
    t.text     "note_text",  :null => false
    t.integer  "user_id",    :null => false
    t.integer  "course_id",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "notes", ["note_text"], :name => "index_notes_on_note_text"

  create_table "repositories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "class_limit",  :default => 0
    t.integer  "user_id"
    t.boolean  "can_edit"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.text     "calendar"
    t.string   "landing_page"
  end

  add_index "repositories", ["can_edit"], :name => "index_repositories_on_can_edit"
  add_index "repositories", ["class_limit"], :name => "index_repositories_on_class_limit"
  add_index "repositories", ["description"], :name => "index_repositories_on_description"
  add_index "repositories", ["name"], :name => "index_repositories_on_name"

  create_table "repositories_rooms", :id => false, :force => true do |t|
    t.integer "repository_id"
    t.integer "room_id"
  end

  create_table "repositories_staff_involvements", :id => false, :force => true do |t|
    t.integer "staff_involvement_id"
    t.integer "repository_id"
  end

  create_table "repositories_users", :id => false, :force => true do |t|
    t.integer "repository_id"
    t.integer "user_id"
  end

  create_table "rooms", :force => true do |t|
    t.string   "name"
    t.integer  "location_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "class_limit", :default => 0
  end

  add_index "rooms", ["name"], :name => "index_rooms_on_name"

  create_table "staff_involvements", :force => true do |t|
    t.string   "involvement_text"
    t.integer  "repository_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "staff_involvements", ["involvement_text"], :name => "index_staff_involvements_on_involvement_text"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",                    :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "admin",                                 :default => false
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.string   "first_name",             :limit => 100
    t.string   "last_name",              :limit => 100
    t.boolean  "staff",                                 :default => false
    t.boolean  "patron",                                :default => true
    t.string   "username",                              :default => "",    :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
