module ListingsHelper

  def get_main_categories
    [:marketplace, :borrow_items, :lost_property, :rides, :groups, :favors, :others]
  end
  
  def get_sub_categories(main_category)
    case main_category
    when "marketplace"
      [:sell, :buy, :give]
    else
      nil
    end  
  end

end
