module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  # rubocop:disable CyclomaticComplexity, Metrics/MethodLength
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'
    when /the signup page/
      '/en/signup'
    when /the private community sign in page/
      '/en/homepage/sign_in'
    when /the english private community sign in page/
      '/en/homepage/sign_in'
    when /the requests page/
      '/en/requests'
    when /the offers page/
      '/en/offers'
    when /the login page/
      login_path(:locale => "en")
    when /the new listing page/
      new_listing_path(:locale => "en")
    when /the edit listing page/
      edit_listing_path(:id => @listing.id, :locale => "en")
    when /^the give feedback path of "(.*)"$/i
      new_person_message_feedback_path(:person_id => @people[$1].id, :message_id => @transaction.id.to_s, :locale => "en")
    when /^the conversation path of "(.*)"$/i
      person_message_path(:person_id => @people[$1].id, :id => @conversation.id.to_s, :locale => "en")
    when /^the conversation page of "(.*)"$/
      single_conversation_path(:person_id => @logged_in_user.id, :conversation_type => "received", :id => $1,  :locale => "en")
    when /^the transaction page of "(.*)"$/
      person_transaction_path(:person_id => @logged_in_user.id, :conversation_type => "received", :id => $1,  :locale => "en")
    when /^the messages page$/i
      person_inbox_path(:person_id => @logged_in_user.id, :locale => "en")
    when /^the profile page of "(.*)"$/i
      person_path(@people[$1], :locale => "en")
    when /^my profile page$/i
      person_path( @logged_in_user, :locale => "en")
    when /the listing page/
      listing_path(:id => @listing.id, :locale => "en")
    when /^the registration page with invitation code "(.*)"$/i
      "/en/signup?code=#{$1}"
    when /^the admin view of community "(.*)"$/i
      admin_details_edit_path(locale: "en")
    when /the infos page/
      about_infos_path(:locale => "en")
    when /the terms page/
      terms_infos_path(:locale => "en")
    when /the privacy policy page/
      privacy_infos_path(:locale => "en")
    when /new tribe in English/
      new_tribe_path(:community_locale => "en", :locale => "en")
    when /invitations page/
      new_invitation_path(:locale => "en")
    when /the settings page/
      "#{person_path(@logged_in_user, :locale => "en")}/settings"
    when /the profile settings page/
      "#{person_path(@logged_in_user, :locale => "en")}/settings"
    when /the account settings page/
      "#{person_path(@logged_in_user, :locale => "en")}/settings/account"
    when /the notifications settings page/
      notifications_person_settings_path(person_id: @logged_in_user.username)
    when /the about page$/
      about_infos_path(:locale => "en")
    when /the feedback page$/
      new_user_feedback_path(:locale => "en")
    when /the custom fields admin page/
      admin_custom_fields_path(:locale => "en")
    when /the categories admin page/
      admin_categories_path(:locale => "en")
    when /the manage members admin page/
      admin_community_community_memberships_path(:community_id => @current_community.id)
    when /the edit look-and-feel page/
      admin_look_and_feel_edit_path
    when /the text instructions admin page/
      edit_text_instructions_admin_community_path(:id => @current_community.id)
    when /the social media admin page/
      social_media_admin_community_path(:id => @current_community.id)
    when /the analytics admin page/
      analytics_admin_community_path(:id => @current_community.id)
    when /the top bar admin page/
      admin_topbar_edit_path
    when /the transactions admin page/
      admin_community_transactions_path(:community_id => @current_community.id)
    when /the conversations admin page/
      admin_community_conversations_path(:community_id => @current_community.id)
    when /the getting started guide for admins/
      admin_getting_started_guide_path
    when /^the admin view of payment preferences of community "(.*)"$/i
      admin_payment_preferences_path(locale: "en")
    when /the order types admin page/
      admin_listing_shapes_path
    when /the edit "(.*)" order type admin page/
      edit_admin_listing_shape_path(id: $1)
    when /the unsubscribe link with code "(.*)" from invitation email to join community/
      unsubscribe_invitations_path(code: $1)
    when /the testimonials admin page/
      admin_community_testimonials_path(:community_id => @current_community.id)
    when /the listings admin page/
      admin_community_listings_path(:community_id => @current_community.id)
    when /the person custom fields admin page/
      admin_person_custom_fields_path(:locale => "en")
    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
  # rubocop:enable CyclomaticComplexity, Metrics/MethodLength
end

World(NavigationHelpers)
