# encoding: utf-8

class ImageUploader < MediumUploader
  include CarrierWave::RMagick

  # Choose what kind of storage to use for this uploader
  storage :file

  version :thumb do
    process :resize_to_fit => [100, 100]
  end 
end
