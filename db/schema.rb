# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101020172720) do

  create_table "case_data", :force => true do |t|
    t.integer  "circuit_case_column_id"
    t.integer  "case_template_id"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "case_data", ["case_template_id"], :name => "index_case_data_on_case_template_id"

  create_table "case_templates", :force => true do |t|
    t.integer  "circuit_id"
    t.integer  "user_id"
    t.string   "objective"
    t.string   "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "case_templates", ["objective"], :name => "index_case_templates_on_objective"
  add_index "case_templates", ["priority"], :name => "index_case_templates_on_priority"
  add_index "case_templates", ["updated_at"], :name => "index_case_templates_on_updated_at"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "parent_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "circuit_access_registries", :force => true do |t|
    t.integer  "circuit_id"
    t.integer  "user_id"
    t.string   "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "circuit_case_columns", :force => true do |t|
    t.string   "name"
    t.integer  "circuit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "circuit_case_columns", ["circuit_id"], :name => "index_circuit_case_columns_on_circuit_id"

  create_table "circuits", :force => true do |t|
    t.text     "name"
    t.text     "description"
    t.integer  "category_id"
    t.text     "source_code"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "context_configurations", :force => true do |t|
    t.string   "name"
    t.string   "view_type"
    t.text     "values"
    t.boolean  "field_default", :default => false
    t.boolean  "enable",        :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_recoveries", :force => true do |t|
    t.integer  "execution_id"
    t.string   "data_name"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_recovery_names", :force => true do |t|
    t.integer  "circuit_id"
    t.string   "name"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.text     "locked_by"
    t.integer  "suite_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "execution_configuration_values", :force => true do |t|
    t.integer  "suite_execution_id"
    t.integer  "context_configuration_id"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "execution_snapshots", :force => true do |t|
    t.integer  "execution_id"
    t.string   "name"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "executions", :force => true do |t|
    t.integer  "circuit_id"
    t.integer  "time_spent",         :default => 0
    t.integer  "user_id"
    t.integer  "case_template_id"
    t.integer  "suite_execution_id"
    t.integer  "status",             :default => 0
    t.text     "error"
    t.text     "position_error"
    t.string   "worker_pid"
    t.text     "output"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "executions", ["case_template_id", "user_id"], :name => "index_executions_on_case_template_id_and_user_id"
  add_index "executions", ["case_template_id"], :name => "index_executions_on_case_template_id"
  add_index "executions", ["suite_execution_id"], :name => "index_executions_on_suite_execution_id"
  add_index "executions", ["updated_at"], :name => "index_executions_on_updated_at"
  add_index "executions", ["user_id"], :name => "index_executions_on_user_id"

  create_table "notes", :force => true do |t|
    t.integer  "user_id"
    t.text     "text"
    t.boolean  "home",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_users", :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "status"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "queue_observers", :force => true do |t|
    t.string   "values",     :limit => 600
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name",              :limit => 40
    t.string   "authorizable_type", :limit => 40
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schematics", :force => true do |t|
    t.integer  "suite_id"
    t.integer  "circuit_id"
    t.integer  "position"
    t.integer  "case_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "suite_cases_relations", :force => true do |t|
    t.integer  "suite_id"
    t.integer  "case_origin"
    t.integer  "case_destination"
    t.integer  "circuit_origin"
    t.integer  "circuit_destination"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "suite_containers", :force => true do |t|
    t.integer  "times"
    t.integer  "suite_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "suite_executions", :force => true do |t|
    t.integer  "suite_id"
    t.integer  "user_id"
    t.integer  "suite_container_id"
    t.string   "identifier",         :limit => 50, :default => " "
    t.integer  "project_id"
    t.integer  "time_spent",                       :default => 0
    t.integer  "status",                           :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "suite_executions", ["suite_id"], :name => "index_suite_executions_on_suite_id"

  create_table "suite_fields_relations", :force => true do |t|
    t.integer  "suite_id"
    t.integer  "circuit_origin_id"
    t.integer  "circuit_destination_id"
    t.string   "field_origin"
    t.string   "field_destination"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "suites", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_configuration_values", :force => true do |t|
    t.integer  "user_configuration_id"
    t.integer  "context_configuration_id"
    t.string   "value",                    :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_configurations", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "send_mail"
    t.boolean  "debug_mode"
    t.string   "remote_control_mode"
    t.string   "remote_control_addr"
    t.string   "remote_control_port"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_functions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.string   "name",        :limit => 50
    t.text     "description"
    t.integer  "cant_args",                 :default => 0
    t.text     "source_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_links", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "name"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.boolean  "active",                                  :default => true
    t.string   "language",                  :limit => 5,  :default => "en_US"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "versions", :force => true do |t|
    t.integer  "versioned_id"
    t.string   "versioned_type"
    t.text     "changes"
    t.integer  "number"
    t.datetime "created_at"
    t.string   "message",        :default => ""
    t.integer  "user_id"
    t.datetime "updated_at"
  end

  add_index "versions", ["created_at"], :name => "index_versions_on_created_at"
  add_index "versions", ["number"], :name => "index_versions_on_number"
  add_index "versions", ["versioned_type", "versioned_id"], :name => "index_versions_on_versioned_type_and_versioned_id"

end
