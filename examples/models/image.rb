class Image < Medium
  set_table_name 'media'

  mount_uploader :file, ImageUploader

  def self.handle_content_type?(content_type)
    content_type.starts_with? 'image/'
  end
end
