class Pdf < Medium
  set_table_name 'media'

  mount_uploader :file, PdfUploader

  def self.handle_content_type?(content_type)
    content_type.include?('pdf')
  end
end
