class Audio < Medium
  set_table_name 'media'

  mount_uploader :file, AudioUploader

  def self.handle_content_type?(content_type)
    content_type.starts_with? 'audio/'
  end

  def public_filename
    final_name = self.filename.gsub /\.[^.]+$/, '.mp3'
    File.join(public_path, final_name)
  end 
end
