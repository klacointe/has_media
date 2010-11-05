class Image < Medium
  set_table_name 'media'
  mount_uploader :file, ImageUploader
end
