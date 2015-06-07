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

ActiveRecord::Schema.define(:version => 20150607183216) do

  create_table "additional_patrons", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.integer  "course_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "role"
  end

  create_table "affiliates", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.text     "description"
    t.integer  "customization_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "position"
  end

  add_index "affiliates", ["position"], :name => "index_affiliates_on_position"

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
    t.text     "comments"
    t.integer  "course_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
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

  create_table "attached_images", :force => true do |t|
    t.string   "image"
    t.string   "caption"
    t.integer  "picture_id"
    t.string   "picture_type"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.boolean  "featured"
  end

  add_index "attached_images", ["featured"], :name => "index_attached_images_on_featured"
  add_index "attached_images", ["picture_id", "picture_type"], :name => "index_attached_images_on_picture_id_and_picture_type"

  create_table "collections", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "url"
    t.integer  "repository_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "collections", ["repository_id"], :name => "index_collections_on_repository_id"

  create_table "courses", :force => true do |t|
    t.string   "title"
    t.string   "subject"
    t.string   "course_number"
    t.string   "affiliation"
    t.string   "contact_email",           :limit => 150, :null => false
    t.string   "contact_phone",           :limit => 25,  :null => false
    t.datetime "pre_class_appt"
    t.datetime "pre_class_appt_choice_1"
    t.datetime "pre_class_appt_choice_2"
    t.datetime "pre_class_appt_choice_3"
    t.integer  "repository_id"
    t.text     "staff_involvement"
    t.integer  "number_of_students"
    t.string   "status"
    t.string   "syllabus"
    t.string   "external_syllabus"
    t.string   "duration"
    t.text     "comments"
    t.integer  "session_count"
    t.text     "goal"
    t.string   "instruction_session"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "contact_first_name",      :limit => 100
    t.string   "contact_last_name",       :limit => 100
    t.string   "contact_username",        :limit => 100
    t.integer  "primary_contact_id"
    t.integer  "section_count"
    t.integer  "total_attendance"
    t.datetime "first_date"
    t.datetime "last_date"
    t.boolean  "scheduled"
    t.integer  "assisting_repository_id"
    t.text     "collaboration_options"
  end

  add_index "courses", ["affiliation"], :name => "index_courses_on_affiliation"
  add_index "courses", ["contact_email"], :name => "index_courses_on_contact_email"
  add_index "courses", ["contact_phone"], :name => "index_courses_on_contact_phone"
  add_index "courses", ["course_number"], :name => "index_courses_on_course_number"
  add_index "courses", ["duration"], :name => "index_courses_on_duration"
  add_index "courses", ["first_date", "last_date"], :name => "index_courses_on_first_date_and_last_date"
  add_index "courses", ["instruction_session"], :name => "index_courses_on_instruction_session"
  add_index "courses", ["pre_class_appt"], :name => "index_courses_on_pre_class_appt"
  add_index "courses", ["scheduled"], :name => "index_courses_on_scheduled"
  add_index "courses", ["session_count", "section_count", "total_attendance"], :name => "courses_index_sessions_sections_attendance"
  add_index "courses", ["session_count"], :name => "index_courses_on_session_count"
  add_index "courses", ["staff_involvement"], :name => "index_courses_on_staff_involvement"
  add_index "courses", ["status"], :name => "index_courses_on_status"
  add_index "courses", ["subject"], :name => "index_courses_on_subject"
  add_index "courses", ["title"], :name => "index_courses_on_title"

  create_table "courses_item_attributes", :id => false, :force => true do |t|
    t.integer "item_attribute_id"
    t.integer "course_id"
  end

  create_table "courses_staff_services", :id => false, :force => true do |t|
    t.integer "course_id"
    t.integer "staff_service_id"
  end

  create_table "courses_users", :id => false, :force => true do |t|
    t.integer "course_id"
    t.integer "user_id"
  end

  create_table "custom_texts", :force => true do |t|
    t.string   "key"
    t.text     "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "customizations", :force => true do |t|
    t.string   "institution"
    t.string   "institution_long"
    t.string   "tool_name"
    t.string   "tool_tech_admin_name"
    t.string   "tool_tech_admin_email"
    t.string   "tool_content_admin_name"
    t.string   "tool_content_admin_email"
    t.string   "default_email_sender"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.string   "slogan"
    t.boolean  "notifications_on"
    t.text     "collaboration_options"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "emails", :force => true do |t|
    t.text     "to"
    t.string   "bcc"
    t.string   "from"
    t.string   "reply_to"
    t.string   "subject"
    t.text     "body"
    t.date     "date_sent"
    t.boolean  "message_sent", :default => false, :null => false
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

  create_table "notes", :force => true do |t|
    t.text     "note_text",                        :null => false
    t.integer  "user_id",                          :null => false
    t.integer  "course_id",                        :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "staff_comment", :default => false, :null => false
    t.boolean  "auto",          :default => false
  end

  add_index "notes", ["note_text"], :name => "index_notes_on_note_text"

  create_table "repositories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "class_limit",    :default => 0
    t.integer  "user_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.text     "calendar"
    t.string   "landing_page"
    t.text     "class_policies"
    t.text     "email_details"
  end

  add_index "repositories", ["class_limit"], :name => "index_repositories_on_class_limit"
  add_index "repositories", ["description"], :name => "index_repositories_on_description"
  add_index "repositories", ["name"], :name => "index_repositories_on_name"

  create_table "repositories_rooms", :id => false, :force => true do |t|
    t.integer "repository_id"
    t.integer "room_id"
  end

  create_table "repositories_staff_services", :id => false, :force => true do |t|
    t.integer "repository_id"
    t.integer "staff_service_id"
  end

  create_table "repositories_users", :id => false, :force => true do |t|
    t.integer "repository_id"
    t.integer "user_id"
  end

  create_table "rooms", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "class_limit", :default => 0
  end

  add_index "rooms", ["name"], :name => "index_rooms_on_name"

  create_table "sections", :force => true do |t|
    t.datetime "requested_dates",                                 :array => true
    t.datetime "actual_date"
    t.integer  "session",          :default => 1, :null => false
    t.integer  "course_id"
    t.integer  "room_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "headcount"
    t.integer  "session_duration"
  end

  add_index "sections", ["actual_date"], :name => "index_sections_on_actual_date"
  add_index "sections", ["course_id"], :name => "index_sections_on_course_id"
  add_index "sections", ["session_duration"], :name => "index_sections_on_session_duration"

  create_table "staff_services", :force => true do |t|
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.boolean  "required"
    t.boolean  "global"
  end

  add_index "staff_services", ["description"], :name => "index_staff_involvements_on_involvement_text"

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
    t.boolean  "admin",                                 :default => false, :null => false
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.string   "first_name",             :limit => 100
    t.string   "last_name",              :limit => 100
    t.boolean  "staff",                                 :default => false, :null => false
    t.boolean  "patron",                                :default => true,  :null => false
    t.string   "username",                              :default => "",    :null => false
    t.boolean  "superadmin",                            :default => false, :null => false
    t.boolean  "pinuser",                               :default => false, :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
