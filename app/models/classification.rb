# Classification module contains methods that are common to Category and ShareType
module Classification
  
  def display_name
    if I18n.locale
       Rails.cache.fetch("/classification_translations/#{id}/#{I18n.locale}/#{updated_at}") do
        if translation(I18n.locale)
          translation(I18n.locale).name
        else
          name
        end
      end
    end
  end
  
  def description
    if I18n.locale && translation(I18n.locale)
      translation(I18n.locale).description || display_name
    else
      name
    end
  end
  
  def transaction_button_text
    translation(I18n.locale).transaction_button_text if translation(I18n.locale)
  end
  
  # returns the classification object which is highest in the hierarchy starting from self.
  def top_level_parent
    if parent
      parent.top_level_parent
    else
      self
    end
  end
  
  def icon_name
    return icon if ApplicationHelper.icon_specified?(icon)
    return name if ApplicationHelper.icon_specified?(name)
    return parent.icon_name if parent
    return "other"
  end
  
  #returns a flattened array of all child objects, including self
  def with_all_children
    
    # first add self
    child_array = [self] 
    
    # Then add children with their children too
    children.each do |child|
      child_array << child.with_all_children
    end
    
    return child_array.flatten
  end
  
  
  
  private
  
  def name_is_not_taken_by_categories_or_share_types
    if (Category.find_by_name(name).present? && Category.find_by_name(name) != self) ||
        (ShareType.find_by_name(name).present? && ShareType.find_by_name(name) != self)
      errors.add(:name, "is already in use by a category or share type")
    end
  end
  
  def translation(locale)
    translations.where(:locale => locale).first
  end
end