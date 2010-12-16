# encoding: UTF-8
require 'rubygems'
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rake'
require 'rake/rdoctask'

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'HasMedia'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

#begin
#  require 'jeweler'
#  Jeweler::Tasks.new do |gem|
#    gem.name = "has_media"
#    gem.summary = %Q{Media Managment Library for ActiveRecord and Carrierwave}
#    gem.description = %Q{Media Managment Library for ActiveRecord and Carrierwave}
#    gem.email = "kevinlacointe@gmail.com"
#    gem.homepage = "http://github.com/klacointe/has_media"
#    gem.authors = ["klacointe", "spk"]
#    gem.add_development_dependency "rspec", "~>2.0.0"
#    gem.add_dependency('carrierwave', '~>0.5')
#    gem.add_dependency('activerecord', '~>3.0.0')
#    gem.add_dependency('activesupport', '~>3.0.0')
#    gem.add_dependency('mime-types', '~>1.16')
#    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
#  end
#rescue LoadError
#  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
#end
