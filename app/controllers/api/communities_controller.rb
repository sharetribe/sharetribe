class Api::CommunitiesController < Api::ApiController
  
  before_filter :find_community, :only => [:show, :classifications]
  
  def show
    respond_with @community
  end
  
  def classifications    
    @classifications = {}
    
    @community.community_categories.each do |cc|
      if cc.price_quantity_placeholder 
        price_quantity_placeholder  = t("listings.form.price.#{cc.price_quantity_placeholder}")
      else
        price_quantity_placeholder = nil
      end
      
      if cc.share_type
        unless @classifications[cc.share_type.name]
          @classifications[cc.share_type.name] = 
              {:translated_name => cc.share_type.display_name, 
                :description => cc.share_type.description,
                :price => cc.price,
                :price_quantity_placeholder => price_quantity_placeholder,
                :payment => cc.payment
              }
        end
      end
      if cc.category
        unless @classifications[cc.category.name]
          

            
          @classifications[cc.category.name] = 
              {:translated_name => cc.category.display_name, 
                :description => cc.category.description,
                :price => cc.price,
                :price_quantity_placeholder => price_quantity_placeholder,
                :payment => cc.payment}
        end
      end
    end
     
    respond_with @classifications.to_json
  end
  
  
  def find_community
    @community = Community.find_by_id(params[:id])
    
    if @community.nil?
      response.status = 404
      render :json => ["No community found with given ID"] and return
    end
  end
end
