module UserService::API
  module Users

    module_function

    def create_user_and_make_a_member_of_community(user, community, invitation = nil)


       # Check that email is not taken
    # unless Email.email_available?(params[:person][:email])
    #   flash[:error] = t("people.new.email_is_in_use")
    #   redirect_to error_redirect_path and return
    # end


    @person, email = new_person(params, @current_community)


    make_user_a_member_of_community(@person, @current_community, invitation)


    # # send email confirmation
    # # (unless disabled for testing environment)
    # if APP_CONFIG.skip_email_confirmation
    #   email.confirm!
    # else
    #   Email.send_confirmation(email, request.host_with_port, @current_community)
    # end

    end

    # TODO move to marketplace service
    def make_user_a_member_of_community(user, community, invitation=nil)
      membership = CommunityMembership.new(:person => user, :community => community, :consent => community.consent)
      membership.status = "pending_email_confirmation"
      membership.invitation = invitation if invitation.present?
      # If the community doesn't have any members, make the first one an admin
      if community.members.count == 0
        membership.admin = true
      end
      membership.save!
      session[:invitation_code] = nil  #TODO Move
    end


    # TODO change to accept pure hash data as params
    # Create a new user by params and optional current community
    def create_user(params, current_community = nil)
      person = Person.new

      params[:person][:locale] =  params[:locale] || APP_CONFIG.default_locale
      params[:person][:test_group_number] = 1 + rand(4)

      email = Email.new(:person => person, :address => params[:person][:email].downcase, :send_notifications => true)
      params["person"].delete(:email)

      person = build_devise_resource_from_person(person)

      person.emails << email

      person.inherit_settings_from(current_community) if current_community

      if person.save!
        sign_in(resource_name, resource)
      end

      person.set_default_preferences

      [person, email]
    end

  end

end
