class HasMediaGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template('create_media.rb', 'db/migrate', :migration_file_name => 'create_media')
      m.migration_template('create_media_links.rb', 'db/migrate', :migration_file_name => 'create_media_links')
    end
  end
end
