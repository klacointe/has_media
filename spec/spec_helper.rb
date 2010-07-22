$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'spec'
require 'spec/autorun'
require 'rubygems'
require 'action_controller'
require 'action_controller/test_process'
require 'has_media'

dbconfig = {
  :adapter => 'sqlite3',
  :database => ':memory:',
#  :database => 'has_media.sqlite'
}

ActiveRecord::Base.establish_connection(dbconfig)
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(STDOUT)
class TestMigration < ActiveRecord::Migration
  def self.up
    create_table :medium_related_tests, :force => true do |t|
      t.string :name
    end
    create_table :prouts, :force => true do |t|
      t.string :name
    end
    create_table :media, :force => true do |t|
      t.string  :context
      t.string  :content_type
      t.string  :filename
      t.integer :encode_status
      t.string  :type
      t.timestamps
    end
    create_table :media_links, :force => true do |t|
      t.integer :medium_id
      t.integer :mediated_id
      t.string  :mediated_type
      t.timestamps
    end
  end
  def self.down
    drop_table :medium_related_tests
    drop_table :media
    drop_table :media_links
  end
end

Spec::Runner.configure do |config|
    config.before(:all) { TestMigration.up }
    config.after(:all) { TestMigration.down }
    config.after(:each) { Medium.destroy_all; MediaLink.destroy_all; MediumRelatedTest.destroy_all; }
end
