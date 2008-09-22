class MessagesController < ApplicationController
  
  before_filter :logged_in, :only  => [ :create ]
  
  def index
    save_navi_state(['own','inbox','',''])
  end
  
  def create
    @listing = Listing.find(params[:listing_id])
    @listing.messages.create(params[:listing_comment])
    flash[:notice] = "comment_added"  
    respond_to do |format|
      format.html { redirect_to @listing }
      format.js  
    end
  end
  
end
