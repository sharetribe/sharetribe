module ListingsHelper
  
  def translate_error_messages(error_message_groups)
    translated_errors = []
    error_message_groups.each do |error_messages|
      error_messages.each do |message|
        translated_errors << translate_error_message(message)
      end
    end
    return translated_errors  
  end
  
  def translate_error_message(message)
    case message
    when "Title on pakollinen tieto."
      t(:title_is_required)
    when "Title on liian lyhyt (minimi on 2 merkkiä)."
      t(:title_is_too_short)
    when "Title on liian pitkä (maksimi on 50 merkkiä)."
      t(:title_is_too_long)  
    when "Content on pakollinen tieto."
      t(:content_is_required)
    when "Good thru on pakollinen tieto."
      t(:good_thru_is_required)
    when "Language on pakollinen tieto."
      t(:listing_must_have_language)
    when "Image file is not a recognized format"
      t(:image_file_is_not_a_recognized_format)
    when "Image file can't be bigger than 10 megabytes"
      t(:image_file_is_too_big)           
    when "Good thru must not be more than one year"
      t(:good_thru_must_not_be_more_than_year)
    else
      message
    end  
  end
  
  # Creates a dropdown populated with all valid listing categories
  def get_category_select_box
    categories = Listing.get_valid_categories.collect { |category| [t(category), category] }
    selected = {}
    selected[:selected] = params[:category][:category] if params[:category] && params[:category][:category]
    selected[:include_blank] = t(:all_categories)
    select("category", "category", categories, selected) 
  end

end
