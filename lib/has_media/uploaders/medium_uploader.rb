# encoding: utf-8

class MediumUploader < CarrierWave::Uploader::Base
  storage :file

  # Override the directory where uploaded files will be stored
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    type = ActiveSupport::Inflector.underscore(model.class.to_s)
    "#{HasMedia.directory_path}/#{type}/#{model.sha1}/#{model.id.to_s}"
  end

  # see https://gist.github.com/519484
  def root
    HasMedia.directory_path
  end

end
