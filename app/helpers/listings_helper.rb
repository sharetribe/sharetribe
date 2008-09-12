module ListingsHelper

  # Create "show [link_value] listings on page" links for 
  # each link value. Type defines the link target path.
  def create_footer_pagination_links(link_values, type)
    links = []
    per_page_value = params[:per_page] || "10"
    params[:page] = 1 if params[:page]
    link_values.each do |value|
      if per_page_value.eql?(value)
        links << t(value)
      else
        case type
        when "category"
          if params[:category]
            path = listing_category_path(params.merge({:per_page => value}))
          else
            path = listing_category_path("all_categories", :per_page => value)
          end    
        when "search"
          path = search_listings_path(params.merge({:per_page => value}))
        when "search_all"
          path = search_path(params.merge({:per_page => value})) 
        end
        links << link_to(t(value), path)  
      end    
    end
    links.join(" | ")  
  end

end
