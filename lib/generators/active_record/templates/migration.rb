class HasMedia < ActiveRecord::Migration
  def self.up
    create_table :media do |t|
      t.integer  :width
      t.integer  :height
      t.integer  :size
      t.string   :content_type  # required
      t.string   :url
      t.string   :filename      # required
      t.string   :thumbnail
      t.integer  :encode_status # required
      t.string   :type          # required
      t.string   :status
      t.string   :context       # required
      t.timestamps
    end
    add_index :media, :encode_status
    add_index :media, [:type, :context]

    create_table :media_links do |t|
      t.integer :medium_id     # required
      t.integer :mediated_id   # required
      t.string  :mediated_type # required

      t.timestamps
    end
    add_index :media_links, :medium_id
    add_index :media_links, [:mediated_id, :mediated_type]
  end

  def self.down
    drop_table :media
    drop_table :media_links
  end
end
