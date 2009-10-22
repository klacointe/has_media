class MediaLink < ActiveRecord::Base
  belongs_to :medium, :dependent => :destroy
end

