class Audio < Medium
  set_table_name 'media'

  mount_uploader :file, AudioUploader

  def self.handle_content_type?(content_type)
    content_type.starts_with? 'audio/'
  end
end
