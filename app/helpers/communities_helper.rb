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



  #FIXME
  def community_name_locals
    translations = find_community_customizations(:name)
    {
      header: t("admin.communities.edit_details.community_name"),
      info_text: I18n.t("admin.communities.edit_details.edit_community_name_description"),
      input_name: "name",
      translations: translations
    }
  end

  def community_slogan_locals
    translations = find_community_customizations(:slogan)
    {
      header: t("admin.communities.edit_details.community_slogan"),
      info_text: I18n.t("admin.communities.edit_details.edit_community_slogan_description", :see_how_it_looks_like => link_to(t("admin.communities.edit_details.see_how_it_looks_like"))),
      input_name: "slogan",
      translations: translations
    }
  end

  def community_description_locals
    translations = find_community_customizations(:description)
    {
      header: t("admin.communities.edit_details.community_description"),
      info_text: I18n.t("admin.communities.edit_details.edit_community_description_description", :see_how_it_looks_like => link_to(t("admin.communities.edit_details.see_how_it_looks_like"))),
      input_name: "description",
      translations: translations
    }
  end

  def transaction_agreement_label_locals
    #FIXME
    translations = {en: {language: "English", translation: ""}, fi: {language: "Suomi", translation: ""}}#find_community_customizations(:agreement_label)
    {
      header: "",
      info_text: I18n.t("admin.communities.edit_details.transaction_agreement_checkbox_label_description", :see_how_it_looks_like => link_to(t("admin.communities.edit_details.see_how_it_looks_like"), "/")),
      input_name: "transaction_agreement_label",
      translations: translations
    }
  end

  def transaction_agreement_text_locals
    #FIXME
    translations = {en: {language: "English", translation: ""}, fi: {language: "Suomi", translation: ""}}#find_community_customizations(:agreement_content)
    {
      info_text: t("admin.communities.edit_details.transaction_agreement_tos_description", :see_how_it_looks_like => link_to(t("admin.communities.edit_details.see_how_it_looks_like"), "/")),
      input_name: "transaction_agreement_content",
      translations: translations
    }
  end

  def find_community_customizations(customization_key)
    translations = {}

    available_locales.each do |locale_name, locale_value|
      translation = @current_community.community_customizations.find_by_locale(locale_value)[customization_key] || ""
      translations[locale_value] = {language: locale_name, translation: translation};
    end
    translations
  end
  #/FIXME

end
