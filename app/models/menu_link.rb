class MenuLink < ActiveRecord::Base
  belongs_to :community

  def url(locale)
    "http://blog.sharetribe.com"
  end

  def title(locale)
    "Blog"
  end
end