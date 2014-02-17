class Api::CommunitiesController < Api::ApiController
  
  before_filter :find_community, :only => [:show, :classifications]
  
  def show
    respond_with @community
  end
  
  def classifications    
    @classifications = {}
    
    @community.categories.each do |category|
      unless @classifications[category.id]
        @classifications[category.id] = 
            {:translated_name => category.display_name(I18n.locale),
              :price => nil,
              :payment => nil}
      end
    end

    @community.transaction_types.each do |transaction_type|
      unless @classifications[transaction_type.id]
        @classifications[transaction_type.id] = 
            {:translated_name => transaction_type.display_name(I18n.locale),
              :price => transaction_type.price_field,
              :payment => nil
            }
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
