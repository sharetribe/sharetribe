class DashboardController < ApplicationController

  include CommunitiesHelper

  layout "dashboard"

  skip_filter :single_community_only
  skip_filter :dashboard_only, :only => :api
  skip_filter :fetch_community, :only => :api

  def index
    @contact_request = session[:contact_request_sent] ? ContactRequest.find(session[:contact_request_sent]) : ContactRequest.new
  end

  # This is for all the custom "campaign" sites
  def campaign
    redirect_to root and return
    case params[:page_type]
    when "wdc"
      @communities = Community.where(:label => "wdc").order("name")
      render :wdc
    when *["okl","omakotiliitto"]
      @communities = Community.where(:label => "okl").order("name")
      render :okl
    else
      @contact_request = ContactRequest.new
      render :index
    end
  end

end
