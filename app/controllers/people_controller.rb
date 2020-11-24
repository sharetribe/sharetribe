class PeopleController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token, :only => [:create]
  skip_before_action :require_no_authentication, :only => [:new]

  before_action EnsureCanAccessPerson.new(
    :id, error_message_key: "layouts.notifications.you_are_not_authorized_to_view_this_content"), only: :destroy
  before_action EnsureCanAccessPerson.new(
    :id, allow_admin: true, error_message_key: "layouts.notifications.you_are_not_authorized_to_view_this_content"), only: :update

  LOOSER_ACCESS_CONTROL = [
    :check_email_availability,
    :check_email_availability_and_validity,
    :check_invitation_code
  ]

  skip_before_action :cannot_access_if_banned,            only: LOOSER_ACCESS_CONTROL
  skip_before_action :cannot_access_without_confirmation, only: LOOSER_ACCESS_CONTROL
  skip_before_action :ensure_consent_given,               only: LOOSER_ACCESS_CONTROL
  skip_before_action :ensure_user_belongs_to_community,   only: LOOSER_ACCESS_CONTROL

  helper_method :show_closed?

  def show
    @service = Person::ShowService.new(community: @current_community, params: params, current_user: @current_user)
    redirect_to landing_page_path and return unless @service.person
    redirect_to landing_page_path and return if @current_community.private? && !@current_user
    @selected_tribe_navi_tab = "members"
    @seo_service.user = @service.person
  end

  def new
    @selected_tribe_navi_tab = "members"
    redirect_to search_path if logged_in?
    session[:invitation_code] = params[:code] if params[:code]
    @service = Person::SettingsService.new(community: @current_community, params: params,
                                           required_fields_only: true)
    @service.new_person

    @container_class = params[:private_community] ? "container_12" : "container_24"
    @grid_class = params[:private_community] ? "grid_6 prefix_3 suffix_3" : "grid_10 prefix_7 suffix_7"
  end

  def create
    domain = @current_community ? @current_community.full_url : "#{request.protocol}#{request.host_with_port}"
    error_redirect_path = domain + sign_up_path

    if params[:person].blank? || params[:person][:input_again].present? # Honey pot for spammerbots
      flash[:error] = t("layouts.notifications.registration_considered_spam")
      Rails.logger.error "Honey pot: Registration Honey Pot is hit."
      redirect_to error_redirect_path and return
    end

    if @current_community && @current_community.join_with_invite_only? || params[:invitation_code]

      unless Invitation.code_usable?(params[:invitation_code], @current_community)
        # abort user creation if invitation is not usable.
        # (This actually should not happen since the code is checked with javascript)
        session[:invitation_code] = nil # reset code from session if there was issues so that's not used again
        ApplicationHelper.send_error_notification("Invitation code check did not prevent submiting form, but was detected in the controller", "Invitation code error")

        # TODO: if this ever happens, should change the message to something else than "unknown error"
        flash[:error] = t("layouts.notifications.unknown_error")
        redirect_to error_redirect_path and return
      else
        invitation = Invitation.find_by_code(params[:invitation_code].upcase)
      end
    end

    return if email_not_valid(params, error_redirect_path)

    email = nil
    begin
      ActiveRecord::Base.transaction do
        @person, email = new_person(params, @current_community)
      end
    rescue StandardError => e
      flash[:error] = t("people.new.invalid_username_or_email")
      redirect_to error_redirect_path and return
    end

    # Make person a member of the current community
    if @current_community
      membership = CommunityMembership.new(person: @person, community: @current_community, consent: @current_community.consent)
      membership.status = "pending_email_confirmation"
      membership.invitation = invitation if invitation.present?
      # If the community doesn't have any members, make the first one an admin
      if @current_community.members.count == 0
        membership.admin = true
      end
      membership.save!
      session[:invitation_code] = nil
    end

    # If invite was used, reduce usages left
    invitation.use_once! if invitation.present?

    Delayed::Job.enqueue(CommunityJoinedJob.new(@person.id, @current_community.id)) if @current_community

    record_event(flash, "SignUp", method: :email)

    # send email confirmation
    # (unless disabled for testing environment)
    if APP_CONFIG.skip_email_confirmation
      email.confirm!

      redirect_to search_path
    else
      Email.send_confirmation(email, @current_community)

      flash[:notice] = t("layouts.notifications.account_creation_succesful_you_still_need_to_confirm_your_email")
      redirect_to confirmation_pending_path
    end
  end

  def build_devise_resource_from_person(person_params)
    #remove terms part which confuses Devise
    person_params.delete(:terms)
    person_params.delete(:admin_emails_consent)

    # This part is copied from Devise's regstration_controller#create
    build_resource(person_params)
    resource
  end

  def update
    target_user = Person.find_by!(username: params[:id], community_id: @current_community.id)
    if @current_user != target_user
      logger.info "ADMIN ACTION: admin='#{@current_user.id}' update person='#{target_user.id}' params=#{params.inspect}"
    end
    # If setting new location, delete old one first
    if params[:person] && params[:person][:location] && (params[:person][:location][:address].empty? || params[:person][:street_address].blank?)
      params[:person].delete("location")
      if target_user.location
        target_user.location.delete
      end
    end

    #Check that people don't exploit changing email to be confirmed to join an email restricted community
    if params["request_new_email_confirmation"] && @current_community && ! @current_community.email_allowed?(params[:person][:email])
      flash[:error] = t("people.new.email_not_allowed")
      redirect_back(fallback_location: homepage_url) and return
    end

    target_user.set_emails_that_receive_notifications(params[:person][:send_notifications])

    begin
      person_params = person_update_params(params, target_user)

      Maybe(person_params)[:location].each { |loc|
        person_params[:location] = loc.merge(location_type: :person)
      }

      m_email_address = Maybe(person_params)[:email_attributes][:address]
      m_email_address.each { |new_email_address|
        # This only builds the emails, they will be saved when `update_attributes` is called
        target_user.emails.build(address: new_email_address, community_id: @current_community.id)
      }

      if target_user.custom_update(person_params.except(:email_attributes))
        if params[:person][:password]
          #if password changed Devise needs a new sign in.
          bypass_sign_in(target_user)
        end

        m_email_address.each {
          # A new email was added, send confirmation email to the latest address
          Email.send_confirmation(target_user.emails.last, @current_community)
        }

        flash[:notice] = t("layouts.notifications.person_updated_successfully")

        # Send new confirmation email, if was changing for that
        if params["request_new_email_confirmation"]
            target_user.send_confirmation_instructions(request.host_with_port, @current_community)
            flash[:notice] = t("layouts.notifications.email_confirmation_sent_to_new_address")
        end
      else
        flash[:error] = if params[:referer_form] == 'settings'
          target_user.errors.full_messages.join(', ')
        else
          t("layouts.notifications.#{target_user.errors.first}")
                        end
      end
    rescue RestClient::RequestFailed => e
      flash[:error] = t("layouts.notifications.update_error")
    end

    if params[:referer_form] == 'settings' && target_user.errors.empty?
      redirect_to person_settings_path(person_id: target_user.username)
    else
      redirect_back(fallback_location: homepage_url)
    end
  end

  def destroy
    target_user = Person.find_by!(username: params[:id], community_id: @current_community.id)

    has_unfinished = Transaction.unfinished_for_person(target_user).any?
    only_admin = @current_community.is_person_only_admin(target_user)

    return redirect_to search_path if has_unfinished || only_admin

    stripe_del = StripeService::API::Api.accounts.delete_seller_account(community_id: @current_community.id,
                                                                        person_id: target_user.id)
    unless stripe_del[:success]
      flash[:error] =  t("layouts.notifications.stripe_you_account_balance_is_not_0")
      return redirect_to search_path
    end

    # Do all delete operations in transaction. Rollback if any of them fails
    ActiveRecord::Base.transaction do
      Person.delete_user(target_user.id)
      Listing.delete_by_author(target_user.id)
      PaypalAccount.where(person_id: target_user.id, community_id: target_user.community_id).delete_all
      Invitation.where(community: @current_community, inviter: target_user).update_all(deleted: true) # rubocop:disable Rails/SkipsModelValidations
    end

    sign_out target_user
    record_event(flash, 'user', {action: "deleted", opt_label: "by user"})
    flash[:notice] = t("layouts.notifications.account_deleted")
    redirect_to search_path
  end

  def check_username_availability
    target_user = Person.find_by!(username: params[:id], community_id: @current_community.id)
    respond_to do |format|
      format.json { render :json => Person.username_available?(params[:person][:username], @current_community, target_user) }
    end
  end

  def check_email_availability_and_validity
    email = params[:person][:email].to_s.downcase

    allowed_and_available = @current_community.email_allowed?(email) && Email.email_available?(email, @current_community.id)

    respond_to do |format|
      format.json { render json: allowed_and_available }
    end
  end

  # this checks that email is not already in use for anyone (including current user)
  def check_email_availability
    email = params[:person] && params[:person][:email_attributes] && params[:person][:email_attributes][:address]

    respond_to do |format|
      format.json { render json: Email.email_available?(email, @current_community.id) }
    end
  end

  def check_invitation_code
    respond_to do |format|
      format.json { render :json => Invitation.code_usable?(params[:invitation_code], @current_community) }
    end
  end

  def show_closed?
    params[:closed] && params[:closed].eql?("true")
  end

  private

  # Create a new person by params and current community
  def new_person(initial_params, current_community)
    initial_params[:person][:locale] =  params[:locale] || APP_CONFIG.default_locale
    initial_params[:person][:test_group_number] = rand(1..4)
    initial_params[:person][:community_id] = current_community.id

    params = person_create_params(initial_params)
    admin_emails_consent = params[:admin_emails_consent]
    person = Person.new

    email = Email.new(:person => person, :address => params[:email].downcase, :send_notifications => true, community_id: current_community.id)
    params.delete(:email)

    person = build_devise_resource_from_person(params)

    person.emails << email

    person.inherit_settings_from(current_community)

    if person.save!
      sign_in(resource_name, resource)
    end

    person.set_default_preferences
    person.preferences["email_from_admins"] = (admin_emails_consent == "on")
    person.save

    [person, email]
  end


  def person_create_params(params)
    result = params.require(:person).slice(
        :given_name,
        :family_name,
        :display_name,
        :street_address,
        :phone_number,
        :image,
        :description,
        :location,
        :password,
        :password2,
        :locale,
        :email,
        :test_group_number,
        :community_id,
        :admin_emails_consent
    ).permit!
    result.merge(params.require(:person)
      .slice(:custom_field_values_attributes)
      .permit(
        custom_field_values_attributes: [
          :id,
          :type,
          :custom_field_id,
          :person_id,
          :text_value,
          :numeric_value,
          :'date_value(1i)', :'date_value(2i)', :'date_value(3i)',
          selected_option_ids: []
        ]
      )
    )
  end

  def restricted_for_admin_update_permit
    [
      :given_name,
      :family_name,
      :display_name,
      :street_address,
      :phone_number,
      :image,
      :description,
      :username,
      location: [:address, :google_address, :latitude, :longitude],
      custom_field_values_attributes: [
        :id,
        :type,
        :custom_field_id,
        :person_id,
        :text_value,
        :numeric_value,
        :'date_value(1i)', :'date_value(2i)', :'date_value(3i)',
        selected_option_ids: []
      ]
    ]
  end

  def person_update_permit
    [
      :password,
      :password2,
      :min_days_between_community_updates,
      :username,
      send_notifications: [],
      email_attributes: [:address],
      preferences: [
        :email_from_admins,
        :email_about_new_messages,
        :email_about_new_comments_to_own_listing,
        :email_when_conversation_accepted,
        :email_when_conversation_rejected,
        :email_about_new_received_testimonials,
        :email_about_confirm_reminders,
        :email_about_testimonial_reminders,
        :email_about_completed_transactions,
        :email_about_new_payments,
        :email_about_new_listings_by_followed_people,
        :empty_notification
      ]
    ]
  end

  def person_update_params(params, target_user)
    permit_values = restricted_for_admin_update_permit
    if @current_user == target_user
      permit_values += person_update_permit
    end
    params.require(:person).permit(permit_values)
  end

  def email_not_valid(params, error_redirect_path)
    # strip trailing spaces
    params[:person][:email] = params[:person][:email].to_s.downcase.strip

    # Check that email is not taken
    unless Email.email_available?(params[:person][:email], @current_community.id)
      flash[:error] = t("people.new.email_is_in_use")
      redirect_to error_redirect_path
      return true
    end

    # Check that the email is allowed for current community
    if @current_community && ! @current_community.email_allowed?(params[:person][:email])
      flash[:error] = t("people.new.email_not_allowed")
      redirect_to error_redirect_path
      return true
    end

    false
  end
end
