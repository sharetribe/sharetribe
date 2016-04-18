class DomainValidationController < ApplicationController

  skip_before_filter :verify_authenticity_token, :fetch_logged_in_user, :fetch_community_membership

  def index
    if params[:dv_file] == @current_community.dv_test_file_name
      render plain: @current_community.dv_test_file, content_type: "text/plain"
    else
      redirect_to error_not_found_path
    end
  end
end
