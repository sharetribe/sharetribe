class Api::CommunitiesController < Api::ApiController
  
  def show
    @community = Community.find_by_id(params[:id])
    
    if @community.nil?
      response.status = 404
      render :json => ["No community found with given ID"] and return
    end
    
    respond_with @community
  end
end
