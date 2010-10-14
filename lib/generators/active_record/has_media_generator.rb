require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    # Cannot inhérit from ActiveRecord::Generators::Base 
    # see http://groups.google.com/group/rubyonrails-talk/browse_thread/thread/a507ce419076cda2
    class HasMediaGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path("../templates", __FILE__)

      def copy_has_media_migration
        migration_template "migration.rb", "db/migrate/has_media"
      end

      # Implement the required interface for Rails::Generators::Migration.
      # taken from http://github.com/rails/rails/blob/master/activerecord/lib/generators/active_record.rb
      def self.next_migration_number(dirname)
        if ActiveRecord::Base.timestamped_migrations
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
      end

    end
  end
end
