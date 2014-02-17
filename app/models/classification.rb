# Classification module contains methods that are common to Category and ShareType
module Classification
  
  def display_name
    if I18n.locale
       Rails.cache.fetch("/#{self.class.name}_translations/#{id}/#{I18n.locale}/#{updated_at}") do
        if translation(I18n.locale)
          translation(I18n.locale).name
        elsif translations.first.present?
          # if didn't find the correct translation, but find any, use that. It's better than just name string
          translations.first.name
        else
          name
        end
      end
    else
      name
    end
  end
  
  def description
    if I18n.locale && translation(I18n.locale)
      translation(I18n.locale).description || display_name
    else
      name
    end
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
    # This could be moved to Category since TransactionType doesn't have children anymore
    
    # first add self
    child_array = [self] 
    
    # Then add children with their children too
    children.each do |child|
      child_array << child.with_all_children
    end
    
    return child_array.flatten
  end
  
  
  
  private
  
  def translation(locale)
    translations.where(:locale => locale).first
  end
end