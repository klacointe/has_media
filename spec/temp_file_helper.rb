def file_path( *paths )
  File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'media', *paths))
end

def stub_temp_file(filename, mime_type=nil, fake_name=nil)
  raise "#{file_path(filename)} file does not exist" unless File.exist?(file_path(filename))

  t = Tempfile.new(filename)
  FileUtils.copy_file(file_path(filename), t.path)

  # This is stupid, but for some reason rspec won't play nice...
  eval <<-EOF
def t.original_filename; '#{fake_name || filename}'; end
def t.content_type; '#{mime_type}'; end
def t.local_path; path; end
  EOF

  return t
end
