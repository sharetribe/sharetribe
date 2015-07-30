class DomainValidationController < ApplicationController

  skip_before_filter :verify_authenticity_token, :fetch_logged_in_user, :fetch_community_membership
  skip_filter :check_email_confirmation

  def index
    if params[:dv_file] == @current_community.dv_test_file_name
      render text: @current_community.dv_test_file, content_type: "text/plain"
    else
      redirect_to error_not_found_path
    end
  end
end
