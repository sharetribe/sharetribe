class CommunitiesController < ApplicationController
  
  respond_to :html, :json
  
  def index
    @communities = Community.joins(:location).select("communities.id, name, settings, domain, members_count, latitude, longitude")
    respond_with(@communities) do |format|
      format.json { render :json => { :data => @communities } }
      format.html #show the communities map
    end
  end
  
  # def show
  #   @community = Community.find(params[:id])
  # end
  
end
