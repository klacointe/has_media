class Video < Medium
  set_table_name 'media'

  mount_uploader :file, VideoUploader

  def self.handle_content_type?(content_type)
    content_type.starts_with? 'audio/'
  end
end
