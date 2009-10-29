require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "HasMedia" do

  before :all do
    class MediumRelatedTest < ActiveRecord::Base
      include HasMedia
      has_one_medium  :image, :only => :image
      has_many_media  :images, :only => :image
      has_one_medium  :audio, :only => :audio
      has_many_media  :audios, :only => :audio
      has_one_medium  :image_no_encode, :only => :image, :encode => false
      has_one_medium  :pdf, :encode => false
    end
    HasMedia.directory_path = 'tmp'
    HasMedia.directory_uri = '/media'
  end

  before :each do
    @medium = MediumRelatedTest.new
    @image = ActionController::TestUploadedFile.new('spec/fixtures/media/image.jpg', 'image/jpeg')
    @audio = ActionController::TestUploadedFile.new('spec/fixtures/media/audio.wav', 'audio/wav')
    @image_bis = ActionController::TestUploadedFile.new('spec/fixtures/media/image_bis.jpg', 'image/jpeg')
    @pdf = ActionController::TestUploadedFile.new('spec/fixtures/media/lc_pdf_overview_format.pdf', 'application/pdf')
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
    @medium.methods.should include("image")
    @medium.methods.should include("images")
    @medium.methods.should include("audio")
    @medium.methods.should include("audios")
    @medium.methods.should include("pdf")
  end

  it "should define setters" do
    @medium.methods.should include("image=")
    @medium.methods.should include("images=")
    @medium.methods.should include("audio=")
    @medium.methods.should include("audios=")
    @medium.methods.should include("pdf=")
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

end
