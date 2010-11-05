# Set the directory path to use to store media
HasMedia.directory_path = "media"

# Set the base uri to access media
HasMedia.directory_uri = "/media"

# Set the allowed medium types for you application
# Set the allowed mime types for each medium type
#HasMedia.medium_types = {
#  "Image" => ["image/jpeg", "image/png"],
#  "Video" => ["video/mp4"],
#  "Audio" => ["audio/mp3"]
#}

# Set the extension of encoded files to use for each medium types 
# This is used in file_uri and file_path
#HasMedia.encoded_extensions = {
#  :image => 'png',
#  :audio => 'ogg',
#  :video => 'flv'
#}

# Require you uploaders
Dir.glob(File.dirname(__FILE__) + '/../app/uploaders/*.rb').each do |uploader|
  require uploader
end
