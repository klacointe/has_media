class MediaController < ApplicationController
  def destroy
    @medium = Medium.find(params[:id])
    @medium.destroy
    render :template => 'has_media/destroy'
  end
end
