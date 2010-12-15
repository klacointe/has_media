$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'
require 'rspec/core'
require 'rspec/core/rake_task'

require 'action_dispatch'
require 'action_dispatch/testing/test_process'

require 'has_media'

require 'db_helper'
require 'temp_file_helper'

RSpec.configure do |c|
  c.before(:all) do
    TestMigration.up
    # load models and uploaders fixtures
    Dir.glob(File.dirname(__FILE__) + '/fixtures/uploaders/*.rb').each do |uploader|
      require uploader
    end
    Dir.glob(File.dirname(__FILE__) + '/fixtures/models/*.rb').each do |model|
      require model
    end
  end
  c.after(:all) do
    TestMigration.down
  end
  c.after(:each) do
    Medium.destroy_all
    MediaLink.destroy_all
    MediumRelatedTest.destroy_all
  end
end


