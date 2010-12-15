class Pdf < Medium
  set_table_name 'media'
  mount_uploader :file, PdfUploader
end
