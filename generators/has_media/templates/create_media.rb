class CreateMedia < ActiveRecord::Migration
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
  end

  def self.down
    drop_table :media
  end
end
