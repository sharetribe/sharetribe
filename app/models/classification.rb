# Classification module contains methods that are common to Category and ShareType
module Classification
  def display_name
    if I18n.locale && translation(I18n.locale)
      translation(I18n.locale)
    else
      return name
    end
    
  end
  
  def translation(locale)
    translations.where(:locale => locale).first.name
  end
end