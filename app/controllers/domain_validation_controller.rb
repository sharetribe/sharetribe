class DomainValidationController < ApplicationController
  def index
    if params[:dv_file] == @current_community.dv_test_file_name
      render text: @current_community.dv_test_file, content_type: "text/plain"
    else
      redirect_to error_not_found_path
    end
  end
end
