class Medium < ActiveRecord::Base
  set_table_name 'media'

  has_many   :media_links, :foreign_key => :medium_id, :dependent => :destroy
  has_many   :mediated, :through => :media_links

  mount_uploader :file, MediumUploader

  validates_presence_of :context

  ENCODE_WAIT      = 0
  ENCODE_ENCODING  = 1
  ENCODE_SUCCESS   = 2
  ENCODE_FAILURE   = 3
  ENCODE_NOT_READY = 4
  NO_ENCODING      = 5

  EXTENSIONS = {
    :image => 'png',
    :audio => 'mp3',
    :pdf   => 'pdf',
    :video => 'flv'
  }

  # Allowed MIME types for upload
  # need custom configuration
  # TODO: add errors if not type of file
  @@mime_types = {
    :video => HasMedia.videos_content_types,
    :image => HasMedia.images_content_types,
    :audio => ['audio/mpeg', 'audio/x-ms-wma', 'audio/x-wav'],
    :flash => ['application/x-shockwave-flash'],
    :pdf   => ['application/pdf'],
  }

  # TODO : check that carrierwave destroy files on after detroy hook
  after_destroy :remove_file_from_fs
  after_initialize  :set_default_encoding_status


  named_scope :with_context, lambda {|context|
    { :conditions => { :context => context.to_s} }
  }

  def self.sanitize(name)
    name = name.gsub("\\", "/") # work-around for IE
    name = File.basename(name)
    name = name.gsub(/[^a-zA-Z0-9\.\-\+_]/,"_")
    name = "_#{name}" if name =~ /\A\.+\z/
    name = "unnamed" if name.size == 0
    return name.downcase
  end

  # FIXME : get medium types from available classes, use has_media.medium_types
  def self.new_from_value(object, value, context, encode, only)
    only ||= ""
    medium_types = HasMedia.medium_types
    if only != "" and klass = Kernel.const_get(only.capitalize)
      medium_types = [klass]
    end
    klass = medium_types.find do |k|
      if k.respond_to?(:handle_content_type?)
        k.handle_content_type?(value.content_type)
      end
    end
    if klass.nil?
      object.media_errors = [HasMedia.errors_messages[:type_error]]
      return
    end
    medium = klass.new
    medium.filename = self.sanitize(value.original_filename)
    medium.file = value
    medium.content_type = value.content_type
    medium.context = context
    medium.encode_status = (encode == "false" ? NO_ENCODING : ENCODE_WAIT)
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

  ##
  # Delete media file(s) from disk
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
    File.join(HasMedia.directory_uri,
              ActiveSupport::Inflector.underscore(self.type),
              self.id.to_s)
  end

  def file_exists?(thumbnail = nil)
    File.exist?(File.join(Rails.root, 'public', file_uri(thumbnail)))
  end

  def file_extension
    EXTENSIONS[type.to_s.downcase.to_sym]
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
