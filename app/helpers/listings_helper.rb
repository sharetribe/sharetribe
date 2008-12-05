module ListingsHelper
  
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
