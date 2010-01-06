class CreateMediaLinks < ActiveRecord::Migration
  def self.up
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
    drop_table :media_links
  end
end
