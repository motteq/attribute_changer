$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'bundler/setup'
require 'active_model'
require 'factory_girl'
require 'database_cleaner'

Bundler.require

Dir["#{File.dirname(__FILE__)}/fixtures/**/*.rb"].each{|f| require f}
Dir["#{File.dirname(__FILE__)}/factories/**/*.rb"].each{|f| require f}

RSpec.configure do |config|
  config.order = "random"

  config.before :suite do
    DatabaseCleaner.strategy = :truncation
  end
  
  config.before :each do 
    DatabaseCleaner.start
  end

  config.after :each do 
    DatabaseCleaner.clean
  end
end

ActiveRecord::Base.establish_connection({
  adapter: 'sqlite3',
  database: ':memory:'
})

ActiveRecord::Schema.define do
  self.verbose = false

  create_table "attribute_changer_attribute_changes", force: true do |t|
    t.string   "obj_type"
    t.integer  "obj_id"
    t.string   "attrib"
    t.string   "value"
    t.string   "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
