# encoding: utf-8

class ImageUploader < MediumUploader
  storage :file
  raise "this exception is normal, useful for testing"
end

