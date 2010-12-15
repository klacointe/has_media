require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class MediumRelatedTest < ActiveRecord::Base
  include HasMedia
  has_one_medium  :image, :only => :image
  has_many_media  :images, :only => :image
  has_one_medium  :audio, :only => :audio
  has_many_media  :audios, :only => :audio
  has_one_medium  :image_no_encode, :only => :image, :encode => false
  has_one_medium  :pdf, :encode => false
  has_one_medium  :document, :encode => false
end

describe "HasMedia" do

  before :all do
    HasMedia.directory_path = '/tmp'
    HasMedia.directory_uri = '/media'
    HasMedia.medium_types = {
      "Image" => ["image/jpeg"],
      "Audio" => ["audio/wav"],
      "Pdf"   => ["application/pdf"],
      "Video" => ["video/mp4"],
      "Document"  => []
    }
  end

  it "HasMedia is a module" do
    HasMedia.class.should be(Module)
  end

  describe "basic fonctionalities" do

    before :each do
      @medium = MediumRelatedTest.new
      @image = stub_temp_file('image.jpg', 'image/jpeg')
      @audio = stub_temp_file('audio.wav', 'audio/wav')
      @image_bis = stub_temp_file('image_bis.jpg', 'image/jpeg')
      @pdf = stub_temp_file('Conversational_Capital _Explained.pdf', 'application/pdf')
    end

    it 'should not have 2 has_one_medium with same context' do
      lambda {
      class Prout < ActiveRecord::Base
        include HasMedia
        has_one_medium  :prout, :only => :image
        has_one_medium  :prout, :only => :audio
      end
      }.should raise_error(Exception)
    end

    it "should define accessors" do
      @medium.methods.should include(:image)
      @medium.methods.should include(:images)
      @medium.methods.should include(:audio)
      @medium.methods.should include(:audios)
      @medium.methods.should include(:pdf)
    end

    it "should define setters" do
      @medium.methods.should include(:image=)
      @medium.methods.should include(:images=)
      @medium.methods.should include(:audio=)
      @medium.methods.should include(:audios=)
      @medium.methods.should include(:pdf=)
    end

    it "should associate image to mediated object" do
      @medium.image = @image
      @medium.save!
      @medium.image.should_not be_nil
      @medium.image.class.should == Image
    end

    it "should associate audio to mediated object" do
      @medium.audio = @audio
      @medium.save!
      @medium.audio.should_not be_nil
      @medium.audio.class.should == Audio
    end

    it "should associate pdf to mediated object" do
      @medium.pdf = @pdf
      @medium.save!
      @medium.pdf.should_not be_nil
      @medium.pdf.class.should == Pdf
    end

    it "should add both audio and image " do
      @medium.image = @image
      @medium.audio = @audio
      @medium.save!
      @medium.audio.should_not be_nil
      @medium.audio.class.should == Audio
      @medium.audio.filename.should == @audio.original_filename
      @medium.audio.content_type.should == "audio/wav"
      @medium.audio
      @medium.image.should_not be_nil
      @medium.image.class.should == Image
      @medium.image.filename.should == @image.original_filename
      @medium.image.content_type.should == "image/jpeg"
    end

    it "should replace media when in has_one_medium relations" do
      @medium.image = @image_bis
      @medium.save
      @medium.image.filename.should == @image_bis.original_filename
      @medium.reload
      @medium.image = @image
      @medium.save
      @medium.image.filename.should == @image.original_filename
    end

    it "should destroy files from fs when Related Model is destroyed" do
      @medium.image = @image
      @medium.save!
      path = @medium.image.original_file_path
      File.exist?(path).should be_true
      @medium.destroy
      File.exist?(path).should be_false
    end

    [:encoding?, :ready?, :failed?].each do |method|
      [:image, :audio, :images, :audios].each do |context|
        class_eval %{
          it "should responds to #{context}.#{method}" do
            @medium.send("#{context}=", @#{context})
            @medium.save!
            media = @medium.send("#{context}")
            if media.is_a? Array
              media.each do |medium|
                [true, false].include?(medium.send("#{method}"))
              end
            else
              [true, false].include?(media.send("#{method}"))
            end
          end
        }
      end
    end

    it "should add several has_many_media for the same context" do
      @medium.images = [@image, @image_bis]
      @medium.save!
      @medium.media.size.should == 2
    end

    it "should have the right encode status" do
      @medium.image_no_encode = @image
      @medium.save!
      @medium.image_no_encode.encode_status.should == Medium::NO_ENCODING
      @medium.image = @image_bis
      @medium.save!
      @medium.image.encode_status.should == Medium::ENCODE_WAIT
    end

    it "should have an original uri" do
      @medium.image = @image
      @medium.save!
      @medium.image.original_file_uri.should == File.join(HasMedia.directory_uri,
                                                          ActiveSupport::Inflector.underscore(@medium.image.type),
                                                          @medium.image.id.to_s,
                                                          @medium.image.filename)
    end

    it "should define file_uri for custom versions" do
      @medium.image = @image
      @medium.save!
      @medium.image.file_uri(:thumb).should == "/media/image/#{@medium.image.id}/image_thumb.png"
      @medium.image.file_path(:thumb).should == "/tmp/image/#{@medium.image.id}/image_thumb.png"
    end

    it "should define file url for carrierwave versions" do
      @medium.image = @image
      @medium.save!
      @medium.image.file.thumb.url.should == "/media/image/#{@medium.image.id}/thumb_image.jpg"
    end

    it "should define file path for carrierwave versions" do
      @medium.image = @image
      @medium.save!
      @medium.image.file.thumb.path.should == "/tmp/image/#{@medium.image.id}/thumb_image.jpg"
    end

    it "pdf should exist" do
      @medium.pdf = @pdf
      @medium.save!
      path = @medium.pdf.file_path
      File.exist?(path).should be_true
    end

    it "should add errors on parent model if type is not allowed" do
      @image = stub_temp_file('image.jpg', 'image/jpeg')
      @medium.audio = @image
      @medium.valid?
      @medium.should_not be_valid
      @medium.save.should be_false
      @medium.errors.full_messages.include?(HasMedia.errors_messages[:type_error])
    end

    it "should sanitize filename" do
      @pdf = stub_temp_file('Conversational_Capital _Explained.pdf', 'application/pdf')
      @medium = MediumRelatedTest.new
      @medium.pdf = @pdf
      @medium.save
      @medium.pdf.filename.should == "conversational_capital__explained.pdf"
      @medium.pdf.original_file_uri.should == "/media/pdf/#{@medium.pdf.id}/conversational_capital__explained.pdf"
    end
  end

  describe "Configuration" do

    it "should configure medium_types" do
      old_conf = HasMedia.medium_types
      HasMedia.medium_types = {
        "Image" => ["image/jpeg"]
      }
      HasMedia.medium_types.should == {
        "Image" => ["image/jpeg"]
      }
      HasMedia.medium_types = old_conf
    end

    it "should configure encoded_extensions" do
      old_conf = HasMedia.encoded_extensions
      HasMedia.encoded_extensions = {
        :image => "png"
      }
      HasMedia.encoded_extensions.should == {
        :image => "png"
      }
      HasMedia.encoded_extensions = old_conf
    end

    it "should configure directory_path" do
      old_conf = HasMedia.directory_path
      HasMedia.directory_path = "/tmp"
      HasMedia.directory_path.should == "/tmp"
      HasMedia.directory_path = old_conf
    end

    it "should configure directory_uri" do
      old_uri = HasMedia.directory_uri
      HasMedia.directory_uri = "/tmp"
      HasMedia.directory_uri.should == "/tmp"
      HasMedia.directory_uri = old_uri
    end

    it "should configure/merge errors_messages" do
      old_conf = HasMedia.errors_messages
      HasMedia.errors_messages = {
        :type_error => "wtf?"
      }
      HasMedia.errors_messages.should == {
        :type_error => "wtf?"
      }
      HasMedia.errors_messages = {
        :another_error => "warning!"
      }
      HasMedia.errors_messages.should == {
        :type_error => "wtf?",
        :another_error => "warning!"
      }
      HasMedia.errors_messages = old_conf
    end

    it "should check allowed medium types if no :only option given" do
      HasMedia.medium_types = {
        "Image" => ["image/jpeg"],
      }
      @pdf = stub_temp_file('Conversational_Capital _Explained.pdf', 'application/pdf')
      @medium = MediumRelatedTest.new
      @medium.pdf = @pdf
      @medium.valid?
      @medium.should_not be_valid
      @medium.save.should be_false
      @medium.errors.full_messages.include?(HasMedia.errors_messages[:type_error])
    end
    it "should check allowed mime type" do
      HasMedia.medium_types = {
        "Pdf" => ["image/jpeg"],
      }
      @pdf = stub_temp_file('Conversational_Capital _Explained.pdf', 'application/pdf')
      @medium = MediumRelatedTest.new
      @medium.pdf = @pdf
      @medium.valid?
      @medium.should_not be_valid
      @medium.save.should be_false
      @medium.errors.full_messages.include?(HasMedia.errors_messages[:type_error])
    end
    it "should allow to accept all mime types" do
      HasMedia.medium_types = {
        "Document" => [],
      }
      @pdf = stub_temp_file('Conversational_Capital _Explained.pdf', 'application/pdf')
      @medium = MediumRelatedTest.new
      @medium.document = @pdf
      @medium.valid?
      @medium.should be_valid
      @medium.save.should be_true
      @image = stub_temp_file('image.jpg', 'image/jpeg')
      @medium.document = @image
      @medium.valid?
      @medium.should be_valid
      @medium.save.should be_true
      @audio = stub_temp_file('audio.wav', 'audio/wav')
      @medium.document = @audio
      @medium.valid?
      @medium.should be_valid
      @medium.save.should be_true
    end
  end

end
