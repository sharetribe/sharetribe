module CommunitiesHelper

  def community_email_restricted?
    ["university", "company"].include? session[:community_category]
  end

  def new_community_email_label
    if ["university", "company"].include? session[:community_category]
      t(".your_#{session[:community_category]}_email")
    else
      t('.your_email')
    end
  end

end
