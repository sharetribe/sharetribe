class ListingCommentsController < ApplicationController

  before_filter :logged_in

  def create
    @listing = Listing.find(params[:listing_id])
    params[:listing_comment][:listing_id] = @listing.id.to_s
    @comment = ListingComment.new(params[:listing_comment])
    @comment.is_read = (@comment.author.id == @listing.author.id) ? 1 : 0
    if @comment.save
      MailWorker.async_send_mail_about_comment_to_listing(:comment_id => @comment.id,
                                                          :host => request.host.to_s)
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
