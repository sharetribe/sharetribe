module UserService::API
  module Users

    module_function

    def create_user_with_membership(user_hash, community_id, invitation_id = nil)

      user = create_user(user_hash, community_id)

      # The first member will be made admin
      MarketplaceService::API::Memberships::make_user_a_member_of_community(user[:id], community_id, invitation_id)

      email = Email.find_by_person_id!(user[:id])
      community = Community.find(community_id)

      # send email confirmation (unless disabled for testing environment)
      if APP_CONFIG.skip_email_confirmation
        email.confirm!
      else
        Email.send_confirmation(email, community.full_domain, community)
      end

      return user
    end

    # TODO make people controller use this method too
    # The challenge for that is the devise connections
    #
    # Create a new user by params and optional current community
    def create_user(params, community_id = nil)
      raise "Email #{params[:person][:email]} is already in use." unless Email.email_available?(params[:person][:email])

      params[:person][:locale] =  params[:locale] || APP_CONFIG.default_locale
      params[:person][:test_group_number] = 1 + rand(4)

      params[:person][:username] = available_username_based_on(params[:person][:email].split("@").first)

      person = Person.new(params[:person].except(:email))
      email = Email.new(:person => person, :address => params[:person][:email].downcase, :send_notifications => true)

      # TODO check if this is necessary
      #person = build_devise_resource_from_person(person)

      person.emails << email

      person.inherit_settings_from(Community.find(community_id)) if community_id

      person.save!

      person.set_default_preferences

      return from_model(person)
    end

    # Create a User hash from Person model
    def from_model(person)
      hash = HashUtils.compact(
        EntityUtils.model_to_hash(person).merge({
          # This is a spot to modify hash contents if needed
          }))
      return hash
    end

    # returns the same if its available, otherwise "same1", "same2" etc.
    # Changes most special characters to _ to match with current validations
    def available_username_based_on(initial_name)
      if initial_name.blank?
        initial_name = "fb_name_missing"
      end
      current_name = initial_name.gsub(/[^A-Z0-9_]/i,"_")
      current_name = current_name[0..17] #truncate to 18 chars or less (max is 20)

      # use base_name as basis on new variations if current_name is not available
      base_name = current_name
      i = 1
      while Person.find_by_username(current_name) do
        current_name = "#{base_name}#{i}"
        i += 1
      end
      return current_name
    end

  end

end
