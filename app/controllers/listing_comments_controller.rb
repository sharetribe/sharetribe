class ListingCommentsController < ApplicationController

  before_filter :logged_in

  def create
    @listing = Listing.find(params[:listing_id])
    params[:listing_comment][:listing_id] = @listing.id.to_s
    @comment = ListingComment.new(params[:listing_comment])
    @comment.is_read = (@comment.author.id == @listing.author.id) ? 1 : 0
    if @comment.save
      if RAILS_ENV != "development" && !current_user?(@listing.author) && @listing.author.settings.email_when_new_comment == 1
        UserMailer.deliver_notification_of_new_comment(@comment, request)
      end
      @listing.notify_followers(request, false)
      flash[:notice] = "comment_added"  
      respond_to do |format|
        format.html { redirect_to @listing }
        format.js  
      end
    else 
      flash[:error] = :empty_comment_not_accepted 
      redirect_to @listing
    end    
  end

end
