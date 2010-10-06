#require 'rake'
#require 'rake/rdoctask'
#require 'rubygems'
#require 'rspec'
#require 'rspec/core'
#require 'rspec/core/rake_task'
#Spec::Core::RakeTask.new(:spec)

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "has_media"
    gem.summary = %Q{Media Managment Library for ActiveRecord and Carrierwave}
    gem.description = %Q{Media Managment Library for ActiveRecord and Carrierwave}
    gem.email = "kevinlacointe@gmail.com"
    gem.homepage = "http://github.com/AF83/has_media"
    gem.authors = ["klacointe", "spk"]
    gem.add_development_dependency "rspec", "<=1.3.0"
    gem.add_dependency('carrierwave', '<=0.5.0')
    gem.add_dependency('activerecord', '=2.3.8')
    gem.add_dependency('activesupport', '=2.3.8')
    gem.add_dependency('mime-types', '>=1.16')
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

#Spec::Rake::SpecTask.new(:spec) do |spec|
#  spec.libs << 'lib' << 'spec'
#  spec.spec_files = FileList['spec/**/*_spec.rb']
#end
#
#Spec::Rake::SpecTask.new(:rcov) do |spec|
#  spec.libs << 'lib' << 'spec'
#  spec.pattern = 'spec/**/*_spec.rb'
#  spec.rcov = true
#end
#
#task :spec => :check_dependencies
#
#task :default => :spec
#
#Rake::RDocTask.new do |rdoc|
#  version = File.exist?('VERSION') ? File.read('VERSION') : ""
#
#  rdoc.rdoc_dir = 'rdoc'
#  rdoc.title = "has_media #{version}"
#  rdoc.rdoc_files.include('README*')
#  rdoc.rdoc_files.include('lib/**/*.rb')
#end
