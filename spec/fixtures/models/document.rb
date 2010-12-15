class Document < Medium
  set_table_name 'media'
  mount_uploader :file, DocumentUploader
end
