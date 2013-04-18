class Api::CommunitiesController < Api::ApiController
  
  before_filter :find_community, :only => [:show, :classifications]
  
  def show
    respond_with @community
  end
  
  def classifications    
    @classifications = @community.categories.concat(@community.share_types)
    respond_with @classifications
  end
  
  
  def find_community
    @community = Community.find_by_id(params[:id])
    
    if @community.nil?
      response.status = 404
      render :json => ["No community found with given ID"] and return
    end
  end
end
