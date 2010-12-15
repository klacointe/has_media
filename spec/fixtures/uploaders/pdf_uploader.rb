# encoding: utf-8

class PdfUploader < MediumUploader
  storage :file

  # Add a white list of extensions which are allowed to be uploaded
  def extension_white_list
    %w(pdf)
  end
end
