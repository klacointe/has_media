$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'rspec'
require 'rspec/core'
require 'rspec/core/rake_task'
require 'action_controller'
#require 'action_controller/test_process'
require 'action_dispatch'
require 'action_dispatch/testing/test_process'
require 'has_media'

dbconfig = {
  :adapter => 'mysql',
  :database => 'has_media',
  :username => 'test',
  :password => 'test'
}

ActiveRecord::Base.establish_connection(dbconfig)
ActiveRecord::Migration.verbose = false
#ActiveRecord::Base.logger = Logger.new(STDOUT)
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

RSpec.configure do |c|
  c.before(:all) do
    TestMigration.up
  end
  c.before(:each) do
    @real_world = RSpec.world
    RSpec.instance_variable_set(:@world, RSpec::Core::World.new)
  end
  c.after(:all) do
    TestMigration.down
  end
  c.after(:each) do
    RSpec.instance_variable_set(:@world, @real_world)
    Medium.destroy_all
    MediaLink.destroy_all
    MediumRelatedTest.destroy_all
  end
end


def file_path( *paths )
  File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'media', *paths))
end

def stub_temp_file(filename, mime_type=nil, fake_name=nil)
  raise "#{file_path(filename)} file does not exist" unless File.exist?(file_path(filename))

  t = Tempfile.new(filename)
  FileUtils.copy_file(file_path(filename), t.path)

  # This is stupid, but for some reason rspec won't play nice...
  eval <<-EOF
def t.original_filename; '#{fake_name || filename}'; end
def t.content_type; '#{mime_type}'; end
def t.local_path; path; end
  EOF

  return t
end
