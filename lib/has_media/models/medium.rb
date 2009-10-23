class Medium < ActiveRecord::Base
  set_table_name 'media'

  has_many   :media_links, :foreign_key => :medium_id, :dependent => :destroy
  has_many   :mediated, :through => :media_links

  mount_uploader :file, MediumUploader

  validates_presence_of :context

  attr_accessible :label, :description

  ENCODE_WAIT      = 0
  ENCODE_ENCODING  = 1
  ENCODE_SUCCESS   = 2
  ENCODE_FAILURE   = 3
  ENCODE_NOT_READY = 4
  NO_ENCODING      = 5

  EXTENSIONS = {
    :image => 'png',
    :audio => 'mp3',
  }

  # Allowed MIME types for upload
  # need custom configuration
  @@mime_types = {
      :video => ['video/mpeg', 'video/mp4', 'video/quicktime', 'video/x-ms-wmv', 'video/x-flv'],
      :image => ['image/gif', 'image/jpeg', 'image/png', 'image/tiff', 'image/pjpeg'],
      :audio => ['audio/mpeg', 'audio/x-ms-wma', 'audio/x-wav'],
      :flash => ['application/x-shockwave-flash']
  }

  # TODO : check that carrierwave destroy files on after detroy hook
  after_destroy :remove_file_from_fs
  after_initialize  :set_default_encoding_status


  named_scope :with_context, lambda {|context|
    { :conditions => { :context => context.to_s} }
  }

  def self.new_from_value(value, context, encode)
    klass = [Image, Audio].find do |k|
      k.handle_content_type?(value.content_type)
    end
    raise 'wrong class type' if klass.nil?
    medium = klass.new
    medium.filename = value.original_filename.downcase
    medium.file = value
    medium.content_type = value.content_type
    medium.context = context
    if encode == "false"
      medium.encode_status = NO_ENCODING
    else
      medium.encode_status = ENCODE_WAIT
    end
    medium.save
    medium
  end

  ##
  # Is this medium encoding?
  #
  def encoding?
    encode_status == ENCODE_ENCODING
  end

  ##
  # Is this medium ready?
  #
  def ready?
    encode_status == ENCODE_SUCCESS
  end

  ##
  # Has the encoding failed for this medium
  #
  def failed?
    encode_status == ENCODE_FAILURE
  end

  # Used in Image to not validate file-size on a non-uploaded Medium
  def is_file
    self.url
  end

  # I can haz URL?
  def has_url?
    url.present?
  end

  ##
  # Delete media file(s) from disk: FIXME should work for all file types
  #
  def unlink_files
    file = self.full_filename
    File.unlink(file) if File.exists? file
  end

  # Public path to the file originally uploaded.
  def original_file_path
    File.join(directory_path, self.filename)
  end

  # Http uri to the originally file
  def original_file_uri
    File.join(directory_uri, self.filename)
  end

  # System directory to store files
  def directory_path
    self.file.store_dir
  end
  # system path for a medium
  def file_path(thumbnail = nil)
    final_name = filename.gsub /\.[^.]+$/, '.' + file_extension
    final_name[-4,0] = "_#{thumbnail}" if thumbnail
    File.join(directory_path, final_name)
  end

  # http uri for a medium
  def file_uri(thumbnail = nil)
    final_name = filename.gsub /\.[^.]+$/, '.' + file_extension
    final_name[-4,0] = "_#{thumbnail}" if thumbnail
    File.join(directory_uri, final_name)
  end
  # http uri of directory which stores media
  def directory_uri
    File.join(HasMedia.directory_uri, self.type.underscore, self.id.to_s)
  end

  def file_exists?(thumbnail = nil)
    File.exist?(File.join(Rails.root, 'public', file_uri(thumbnail)))
  end

  def file_extension
    EXTENSIONS[type.downcase.to_sym]
  end

private

  ##
  # Set encode_status value to notify the encoder of a new file
  def set_default_encoding_status
    self.encode_status = ENCODE_NOT_READY if filename_changed?
  end

  ##
  # Unlink the folder containing the files
  # TODO : remove all files, not only the original one
  def remove_file_from_fs
    require 'fileutils'
    FileUtils.rm_rf(self.original_file_path)
  end
end
