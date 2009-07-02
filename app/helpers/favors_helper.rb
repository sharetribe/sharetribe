module FavorsHelper
  def favor_div_title(title)
    "favor_#{remove_html_unfriendly_chars(title.downcase)}"
  end
end
