dbconfig = {
  :adapter => 'sqlite3',
  :database => ':memory:',
}

ActiveRecord::Base.establish_connection(dbconfig)
ActiveRecord::Migration.verbose = false
class TestMigration < ActiveRecord::Migration
  def self.up
    create_table :medium_related_tests, :force => true do |t|
      t.string :name
    end
    create_table :media, :force => true do |t|
      t.string  :context
      t.string  :content_type
      t.string  :filename
      t.integer :encode_status
      t.string  :type
      t.string  :file
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

