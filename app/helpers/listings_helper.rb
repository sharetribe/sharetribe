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
          if params[:id]
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
  
  # def translate_error_messages(error_message_groups)
  #   translated_errors = []
  #   error_message_groups.each do |error_messages|
  #     error_messages.each do |message|
  #       translated_errors << translate_error_message(message)
  #     end
  #   end
  #   return translated_errors  
  # end
  # 
  # def translate_error_message(message)
  #   case message
  #   # when "Title on pakollinen tieto."
  #   #   t(:title_is_required)
  #   when "Title on liian lyhyt (minimi on 2 merkkiä)."
  #     t(:title_is_too_short)
  #   when "Content on pakollinen tieto."
  #     t(:content_is_required)
  #   when "Good thru on pakollinen tieto."
  #     "Voimassaoloaika on pakollinen tieto."
  #   when "Language on pakollinen tieto."
  #     "Ilmoituksella on oltava vähintään yksi kieli."       
  #   else
  #     message
  #   end  
  # end

  # <%
  # 
  # <% errors = translate_error_messages([@listing.errors.full_messages]) %>
  # <% unless errors.empty? %>
  # <div id="form_error_messages">
  # <h2><%= t(:listing_cannot_be_created) %></h2>
  # <ul>
  # <% errors.each do |error| %>
  #   <li><%= error %></li>
  # <% end %>
  # </ul>
  # </div>
  # <% end %>
  # 
  # %>

end
