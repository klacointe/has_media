require 'rubygems'
require 'activerecord'
require 'activesupport'
require 'carrierwave'

require File.dirname(__FILE__) + '/has_media/uploaders/medium_uploader'
Dir.glob(File.dirname(__FILE__) + '/has_media/uploaders/*.rb').each do |uploader|
  require uploader
end
require File.dirname(__FILE__) + '/has_media/models/medium'
Dir.glob(File.dirname(__FILE__) + '/has_media/models/*.rb').each do |model|
  require model
end

module HasMedia

  VERSION = "0.0.1"

  @@store_dir = '/tmp'
  @@directory_uri = ''

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

  def self.included(mod)
    mod.extend ClassMethods
  end

  module ClassMethods

    def has_one_medium(context, options = {})
      set_relations(context, :has_one)
      set_media_links_relation
      set_callbacks

      create_one_accessors(context, options)
    end

    def has_many_media(context, options = {})
      set_relations(context, :has_many)
      set_media_links_relation
      set_callbacks

      create_many_accessors(context, options)
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
      before_save :remove_old_media
    end

    def set_media_links_relation
      has_many :media_links, :as => :mediated, :dependent => :destroy
    end

    def create_one_accessors(context, options)
      check_conditions = ''
      check_conditions << "return unless medium.is_a? #{options[:only].to_s.capitalize}" if options.has_key? :only

      define_method(context) do
        media.with_context(context.to_sym).first
      end

      module_eval <<-"end;", __FILE__, __LINE__
        def #{context}=(value)
          return if value.blank?
          medium = Medium.new_from_value(value, "#{context}", "#{options[:encode]}")
          #{check_conditions}
          @old_media ||= []
          @old_media += media.with_context("#{context}")
          media << medium
        end
      end;
    end

    def create_many_accessors(context, options)
      check_conditions = ''
      check_conditions << "return unless medium.is_a? #{options[:only].to_s.capitalize}" if options.has_key? :only

      define_method(context.to_s.pluralize) do
        media.with_context(context.to_sym).uniq
      end

      module_eval <<-"end;", __FILE__, __LINE__
        def #{context}=(values)
          return if values.blank?
          Array(values).each do |value|
            next if value.nil?
            medium = Medium.new_from_value(value, "#{context}", "#{options[:encode]}")
            #{check_conditions}
            media << medium
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
