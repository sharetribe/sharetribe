module CommunitiesHelper

  def new_community_email_label
    if ["university", "company"].include? session[:community_category]
      t("communities.signup_form.your_#{session[:community_category]}_email")
    else
      t('communities.signup_form.your_email')
    end
  end

  def clear_session_variables
    session[:community_category] = session[:pricing_plan] = session[:community_locale] = session[:unconfirmed_email] = session[:confirmed_email] = session[:allowed_email] = nil
  end

  def new_tribe_email_confirmed?
    @current_user.emails.select{|e| e.confirmed_at.present?}.include?(session[:email])
  end

end
