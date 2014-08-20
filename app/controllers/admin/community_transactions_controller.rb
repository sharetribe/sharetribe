class Admin::CommunityTransactionsController < ApplicationController
  before_filter :ensure_is_admin
  skip_filter :dashboard_only

  def index
    community = @current_community
    conversations = ListingConversation
      .where(:community_id => @current_community.id)
      .includes(:listing)
      .paginate(:page => params[:page], :per_page => 50)
      .order("#{sort_column} #{sort_direction}")

    render("index",
      { locals: {
        show_status_and_sum: community.payments_in_use?,
        community: community,
        conversations: conversations
      }}
    )
  end

  private

  def sort_column
    case params[:sort]
    when "listing"
      "listings.title"
    when "started"
      "created_at"
    when "last_activity"
      "last_message_at"
    else
      "last_message_at"
    end
  end

  def sort_direction
    params[:direction] || "desc"
  end
end
