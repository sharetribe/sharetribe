class Admin::CommunityTransactionsController < ApplicationController
  before_filter :ensure_is_admin
  skip_filter :dashboard_only

  def index
    @community = @current_community
    @conversations = ListingConversation.where(:community_id => @current_community.id)
      .includes(:listing)
      .paginate(:page => params[:page], :per_page => 50)
      .order("#{sort_column} #{sort_direction}")
  end

  private

  def sort_column
    case params[:sort]
    # when "listing"
    #   "listings.title"
    # when "status"
    #   "listings.current_state"
    # when "sum"
    #   "listing.payment.total_sum"
    when "started"
      "created_at"
    when "last_activity"
      "last_message_at"
    # when "initiated_by"
    #   "participations.starter."
    # when "other_party"
    #   "participations.starter."
    else
      "last_message_at"
    end
  end

  def sort_direction
    params[:direction] || "desc"
  end
end