# Set the directory path to use to store media
HasMedia.directory_path = "media"

# Set the base uri to access media
HasMedia.directory_uri = "/media"

# Set the allowed medium types for your application (used if no :only option given)
#HasMedia.medium_types = [Image, Video, Audio]

# Set the extension of encoded files to use for each medium types (used in file_uri and file_path)
#HasMedia.encoded_extensions = {
#  :image => 'png',
#  :audio => 'ogg',
#  :video => 'flv'
#}

# Require you uploaders
Dir.glob(File.dirname(__FILE__) + '/../app/uploaders/*.rb').each do |uploader|
  require uploader
end
