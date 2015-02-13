module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  # rubocop:disable CyclomaticComplexity
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
    when /^the testimonials page of "(.*)"$/i
      person_testimonials_path(:person_id => @people[$1].id, :locale => "en")
    when /the listing page/
      listing_path(:id => @listing.id, :locale => "en")
    when /^the registration page with invitation code "(.*)"$/i
      "/en/signup?code=#{$1}"
    when /^the admin view of community "(.*)"$/i
      edit_details_admin_community_path(:id => Community.find_by_domain($1).id, :locale => "en")
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
    when /the new Checkout account page/
      "#{person_path(@logged_in_user, :locale => "en")}/checkout_account/new"
    when /the new Braintree account page/
      "#{person_path(@logged_in_user, :locale => "en")}/settings/payments/braintree/new"
    when /the account settings page/
      "#{person_path(@logged_in_user, :locale => "en")}/settings/account"
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
      edit_look_and_feel_admin_community_path(:id => @current_community.id)
    when /the text instructions admin page/
      edit_text_instructions_admin_community_path(:id => @current_community.id)
    when /the social media admin page/
      social_media_admin_community_path(:id => @current_community.id)
    when /the analytics admin page/
      analytics_admin_community_path(:id => @current_community.id)
    when /the menu links admin page/
      menu_links_admin_community_path(:id => @current_community.id)
    when /the transactions admin page/
      admin_community_transactions_path(:community_id => @current_community.id)
    when /the getting started page for admins/
      getting_started_admin_community_path(:id => @current_community.id)

    # the following are examples using path_to_pickle

    when /^#{capture_model}(?:'s)? page$/                           # eg. the forum's page
      path_to_pickle $1

    when /^#{capture_model}(?:'s)? #{capture_model}(?:'s)? page$/   # eg. the forum's post's page
      path_to_pickle $1, $2

    when /^#{capture_model}(?:'s)? #{capture_model}'s (.+?) page$/  # eg. the forum's post's comments page
      path_to_pickle $1, $2, :extra => $3                           #  or the forum's post's edit page

    when /^#{capture_model}(?:'s)? (.+?) page$/                     # eg. the forum's posts page
      path_to_pickle $1, :extra => $2                               #  or the forum's edit page

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

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
  # rubocop:enable CyclomaticComplexity
end

World(NavigationHelpers)
