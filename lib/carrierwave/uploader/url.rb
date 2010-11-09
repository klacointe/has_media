# encoding: utf-8

module CarrierWave
  module Uploader
    module Url 
      ##  
      # === Returns
      #   
      # [String] the location where this file is accessible via a url
      #   
      def url 
        if file.respond_to?(:url) and not file.url.blank?
          file.url
        elsif current_path
          File.expand_path(current_path).gsub(File.expand_path(root), HasMedia.directory_uri)
        end 
      end 
    end # Url
  end # Uploader
end # CarrierWave
