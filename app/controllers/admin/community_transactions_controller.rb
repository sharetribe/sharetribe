class Admin::CommunityTransactionsController < ApplicationController
  before_filter :ensure_is_admin
  skip_filter :dashboard_only

  def index
      @community = @current_community
      @conversations = Conversation.where(:community_id => @current_community.id)
                                   .paginate(:page => params[:page], :per_page => 50)
  end
end