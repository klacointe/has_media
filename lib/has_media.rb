require 'rubygems'
require 'rails'
require 'active_record'
require 'active_support'
require 'carrierwave'
require 'mime/types'
require 'has_media'

autoload :Medium,         "has_media/models/medium"
autoload :MediaLink,      "has_media/models/media_link"
autoload :MediumUploader, "has_media/uploaders/medium_uploader"

module HasMedia

  class Engine < Rails::Engine

    initializer 'has_media.initializer' do |app|
      # Include HasMedia in all ActiveRecord::Base Object
      class ActiveRecord::Base
        include HasMedia
      end
      # Include HasMediaHelper in all ActiveRecord::Base Object
      class ActionController::Base
        helper HasMediaHelper
      end
    end

  end

  @@medium_types = {}
  @@store_dir = '/tmp'
  @@directory_uri = ''
  @@errors_messages = {:type_error => 'Wrong type'}
  @@encoded_extensions = {
    :image => 'png',
    :audio => 'mp3',
    :pdf   => 'pdf',
    :video => 'flv'
  }

  ##
  # medium_types
  #
  # Used to configure available medium types
  #
  # Each medium type id representing with its class name and contain an Array
  # of possible mime types. An empty Array means no limitation on mime type
  #
  # Example : 
  #  HasMedia.medium_types = {
  #    "Image" => ["image/jpeg", "image/png"],
  #    "Video" => ["video/mp4"],
  #    "Audio" => ["audio/mp3"],
  #    "Document" => []
  #  }
  #
  def self.medium_types=(value)
    @@medium_types = value
  end
  def self.medium_types
    @@medium_types
  end

  ##
  # encoded_extensions
  #
  # Used to configure output format if you use a custom encoder
  #
  # Example :
  #  HasMedia.encoded_extensions = {
  #    :image => 'png',
  #    :audio => 'ogg',
  #    :video => 'flv'
  #  }
  #
  def self.encoded_extensions=(value)
    @@encoded_extensions = value
  end
  def self.encoded_extensions
    @@encoded_extensions
  end

  ##
  # directory_path
  #
  # Used to configure directory_path to store media on filesystem
  #
  # Example :
  #   HasMedia.directory_path = Rails.root + "media"
  #
  def self.directory_path=(value)
    @@store_dir = value
  end
  def self.directory_path
    @@store_dir
  end

  ##
  # directory_uri
  #
  # Used to store www access to your media
  #
  # Example :
  #   HasMedia.directory_path = Rails.root + "media"
  #
  def self.directory_uri=(value)
    @@directory_uri = value
  end
  def self.directory_uri
    @@directory_uri
  end

  ##
  # errors_messages
  #
  # Used to store custom error messages
  #
  # Example :
  #   HasMedia.errors_messages = {:type_error => "Le format du logo n'est pas correct"}
  #
  def self.errors_messages
    @@errors_messages
  end
  def self.errors_messages=(h)
    @@errors_messages.merge!(h)
  end

  def self.included(mod)
    mod.extend ClassMethods
  end

  ##
  # Sanitize file name
  # @param [String] name
  # @return [String]
  #
  def self.sanitize_file_name(name)
    name = name.gsub("\\", "/") # work-around for IE
    name = File.basename(name)
    name = name.gsub(/[^a-zA-Z0-9\.\-\+_]/,"_")
    name = "_#{name}" if name =~ /\A\.+\z/
    name = "unnamed" if name.size == 0
    return name
  end


  module ClassMethods

    ##
    # has_one_medium 
    # Define a class method to link to a medium
    #
    # @param [String] context, the context (or accessor) to link medium
    # @param [Hash]   options, can be one of : encode, only
    #
    def has_one_medium(context, options = {})
      set_relations(context, :has_one)
      set_general_methods
      create_one_accessors(context, options)
    end

    ##
    # has_many_media
    # Define a class method to link to several media
    #
    # @param [String] context, the context (or accessor) to link media
    # @param [Hash]   options, can be one of : encode, only
    #
    def has_many_media(context, options = {})
      set_relations(context, :has_many)
      set_general_methods
      create_many_accessors(context, options)
    end

    ##
    # set_general_methods
    # Add generic methods for has_one_medium and has_many_media
    # Including media_links relation, accessors, callbacks, validation ...
    #
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

    ##
    # set_relations
    # add relation on medium if not exists
    # Also check if a class has a duplicate context
    #
    # @param [String] context
    # @param [String] relation type, one of :has_many, :has_one
    #
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

    ##
    # set_callbacks
    # Add callbacks to :
    #   - merge medium errors to class related errors
    #   - destroy medium
    #
    def set_callbacks
      validate :merge_media_errors
      before_save :remove_old_media
    end

    ##
    # set_attributes
    # Add media_errors attributes to store medium errors
    #
    def set_attributes
      attr_accessor :media_errors
    end

    ##
    # set_validate_methods
    # Define merge_media_errors to merge medium errors with errors given
    # on master object.
    #
    def set_validate_methods
      module_eval <<-"end;", __FILE__, __LINE__
        def merge_media_errors
          self.media_errors ||= []
          self.media_errors.each do |error|
            self.errors.add(:base, error)
          end
        end
      end;
    end
    
    ##
    # set_media_links_relation
    # Declare media_links relation 
    def set_media_links_relation
      has_many :media_links, :as => :mediated, :dependent => :destroy
    end

    ##
    # create_one_accessors
    # Create needed accessors on master object for unique relation
    #
    # @param [String] context
    # @param [Hash]   options
    #
    def create_one_accessors(context, options)
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

    ##
    # create_many_accessors
    # Create needed accessors on master object for multiple relation
    #
    # @param [String] context
    # @param [Hash]   options
    #
    def create_many_accessors(context, options)
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

  ##
  # Remove old media before saving
  #
  def remove_old_media
    (@old_media || []).each do |medium|
      medium.destroy if medium
    end
  end

end

