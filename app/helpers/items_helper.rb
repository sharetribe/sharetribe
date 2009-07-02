module ItemsHelper 
  def item_div_title(item_title)
    "item_#{remove_html_unfriendly_chars(item_title.downcase)}"
  end
end
