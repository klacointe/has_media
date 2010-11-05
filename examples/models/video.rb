class Video < Medium
  set_table_name 'media'
  mount_uploader :file, VideoUploader
end
