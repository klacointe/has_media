class Audio < Medium
  set_table_name 'media'
  mount_uploader :file, AudioUploader
end
