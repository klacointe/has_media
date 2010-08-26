require 'rubygems'
require 'active_record'
require 'active_support'
require 'carrierwave'

module HasMedia

  VERSION = "0.0.1"

  @@medium_types = []
  @@store_dir = '/tmp'
  @@directory_uri = ''
  @@custom_models_path = nil
  @@errors_messages = {:type_error => 'Wrong type'}
  @@images_content_types = [
    'image/jpeg',
    'image/pjpeg',
    'image/jpg',
    'image/gif',
    'image/png',
    'image/x-png',
    'image/jpg',
    'image/x-ms-bmp',
    'image/bmp',
    'image/x-bmp',
    'image/x-bitmap',
    'image/x-xbitmap',
    'image/x-win-bitmap',
    'image/x-windows-bmp',
    'image/ms-bmp',
    'application/bmp',
    'application/x-bmp',
    'application/x-win-bitmap',
    'application/preview',
    'image/jp_',
    'application/jpg',
    'application/x-jpg',
    'image/pipeg',
    'image/vnd.swiftview-jpeg',
    'image/x-xbitmap',
    'application/png',
    'application/x-png',
    'image/gi_',
    'image/x-citrix-pjpeg'
  ]
  @@videos_content_types = [
    'video/mpeg',
    'video/mp4',
    'video/quicktime',
    'video/x-ms-wmv',
    'video/x-flv',
    'video/x-msvideo'
  ]
  @@encoded_extensions = [
    :image => 'png',
    :audio => 'mp3',
    :pdf   => 'pdf',
    :video => 'flv'
  ]

  def self.medium_types=(value)
    @@medium_types = value
  end
  def self.medium_types
    @@medium_types
  end
  def self.directory_path=(value)
    @@store_dir = value
  end
  def self.directory_path
    @@store_dir
  end
  def self.directory_uri=(value)
    @@directory_uri = value
  end
  def self.directory_uri
    @@directory_uri
  end
  def self.custom_models_path
    @@custom_models_path
  end
  def self.custom_models_path=(value)
    unless value.blank?
      @@custom_models_path = value
      Dir.glob(self.custom_models_path + '/*.rb').each do |model|
        require model
      end
    end
  end
  # taken from http://github.com/technoweenie/attachment_fu/blob/master/lib/technoweenie/attachment_fu.rb
  def self.images_content_types
    @@images_content_types
  end
  def self.videos_content_types
    @@videos_content_types
  end
  def self.errors_messages
    @@errors_messages
  end
  def self.errors_messages=(h)
    @@errors_messages.merge!(h)
  end

  def self.included(mod)
    mod.extend ClassMethods
  end

  module ClassMethods

    def has_one_medium(context, options = {})
      set_relations(context, :has_one)
      set_general_methods
      create_one_accessors(context, options)
    end

    def has_many_media(context, options = {})
      set_relations(context, :has_many)
      set_general_methods
      create_many_accessors(context, options)
    end

    def set_general_methods
      @methods_present ||= false
      unless @methods_present
        set_media_links_relation
        set_attributes
        set_validate_methods
        set_callbacks
      end
      @methods_present = true
    end

    def set_relations(context, relation)
      @contexts ||= {}
      @contexts[relation] ||= []
      @media_relation_set ||= []
      if @contexts[relation].include?(context)
        raise Exception.new("You should NOT use same context identifier for several has_one or has_many relation to media")
      end
      @contexts[relation] << context
      return if @media_relation_set.include? self
      has_many :media, :through => :media_links, :dependent => :destroy

      @media_relation_set << self
    end

    def set_callbacks
      validate :merge_media_errors
      before_save :remove_old_media
    end
    def set_attributes
      attr_accessor :media_errors
    end
    def set_validate_methods
      module_eval <<-"end;", __FILE__, __LINE__
        def merge_media_errors
          self.media_errors ||= []
          self.media_errors.each do |error|
            self.errors.add_to_base(error)
          end
        end
      end;
    end

    def set_media_links_relation
      has_many :media_links, :as => :mediated, :dependent => :destroy
    end

    def create_one_accessors(context, options)
      #check_conditions = ''
      #check_conditions << "return unless medium.is_a? #{options[:only].to_s.capitalize}" if options.has_key? :only

      define_method(context) do
        media.with_context(context.to_sym).first
      end

      module_eval <<-"end;", __FILE__, __LINE__
        def #{context}=(value)
          return if value.blank?
          medium = Medium.new_from_value(self, value, "#{context}", "#{options[:encode]}", "#{options[:only]}")
          if medium
            @old_media ||= []
            @old_media += media.with_context("#{context}")
            media << medium
          end
        end
      end;
    end

    def create_many_accessors(context, options)
      #check_conditions = ''
      #check_conditions << "return unless medium.is_a? #{options[:only].to_s.capitalize}" if options.has_key? :only

      define_method(context.to_s.pluralize) do
        media.with_context(context.to_sym).uniq
      end

      module_eval <<-"end;", __FILE__, __LINE__
        def #{context}=(values)
          return if values.blank?
          Array(values).each do |value|
            next if value.nil?
            medium = Medium.new_from_value(self, value, "#{context}", "#{options[:encode]}", "#{options[:only]}")
            media << medium if medium
          end
        end
      end;
    end
  end

  def remove_old_media
    (@old_media || []).each do |medium|
      medium.destroy if medium
    end
  end

end

class ActiveRecord::Base
  include HasMedia
end

require File.dirname(__FILE__) + '/has_media/uploaders/medium_uploader'
Dir.glob(File.dirname(__FILE__) + '/has_media/uploaders/*.rb').each do |uploader|
  require uploader
end

require File.dirname(__FILE__) + '/has_media/models/medium'
Dir.glob(File.dirname(__FILE__) + '/has_media/models/*.rb').each do |model|
  require model
end
