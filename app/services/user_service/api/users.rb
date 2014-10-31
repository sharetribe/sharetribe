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




    # TODO change to accept pure hash data as params
    # TODO make people controller use this method too
    # The challenge for that is the devise connections
    # Create a new user by params and optional current community
    def create_user(params, current_community = nil)


      params[:person][:locale] =  params[:locale] || APP_CONFIG.default_locale
      params[:person][:test_group_number] = 1 + rand(4)

      # TODO use code inside service only. (move this method to service and call
      # that from earlier usage places too)
      params[:person][:username] = Person.available_username_based_on(params[:person][:email].split("@").first)

      person = Person.new(params[:person].except(:email))
      email = Email.new(:person => person, :address => params[:person][:email].downcase, :send_notifications => true)
      #params["person"].delete(:email)

      # TODO check if this is necessary
      #person = build_devise_resource_from_person(person)

      person.emails << email

      person.inherit_settings_from(current_community) if current_community

      person.save!
      # if person.save!
      #   sign_in(resource_name, resource)
      # end

      person.set_default_preferences

      return person
    end

  end

end
