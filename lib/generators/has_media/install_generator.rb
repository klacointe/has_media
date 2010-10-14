module HasMedia
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a HasMedia initializer, migration and copy locale files to your application."

      def copy_initializer
        template "has_media.rb", "config/initializers/has_media.rb"
      end

      def copy_locale
        copy_file "../../../config/locales/en.yml", "config/locales/has_media.en.yml"
      end

      hook_for :orm, :as => "has_media"

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
