# Classification module contains methods that are common to Category and ShareType
module Classification
  def display_name
    if I18n.locale && translation(I18n.locale)
      translation(I18n.locale)
    else
      return name
    end
    
  end
  
  def translation(locale=I18n.locale)
    translation = translations.where(:locale => locale)
     if translation.empty?
       name
     else
       translation.first.name
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
  
end