# encoding: utf-8

class MediumUploader < CarrierWave::Uploader::Base

  # Choose what kind of storage to use for this uploader
  storage :file
  #     storage :s3

  # Override the directory where uploaded files will be stored
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    type = ActiveSupport::Inflector.underscore(model.class.to_s)
    "#{HasMedia.directory_path}/#{type}/#{model.id}"
  end
end
