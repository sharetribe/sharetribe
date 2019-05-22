class CommunityMembershipsController < ApplicationController

  before_action do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_this_page")
  end

  skip_before_action :cannot_access_if_banned
  skip_before_action :cannot_access_without_confirmation
  skip_before_action :ensure_consent_given
  skip_before_action :ensure_user_belongs_to_community

  before_action :ensure_membership_found
  before_action :ensure_membership_is_not_accepted
  before_action only: [:pending_consent, :give_consent] {
    ensure_membership_status("pending_consent")
  }
  before_action only: [:confirmation_pending] {
    ensure_membership_status("pending_email_confirmation")
  }

  Form = EntityUtils.define_builder(
    [:invitation_code, :string],
    [:email, :string],
    [:consent, one_of: [nil, "on"]]
  )

  def pending_consent
    render_pending_consent_form(invitation_code: session[:invitation_code])
  end

  def give_consent
    form_params = params[:form] || {}
    values = Form.call(form_params)

    invitation_check = ->() {
      if @current_community.join_with_invite_only?
        validate_invitation_code(invitation_code: values[:invitation_code],
                                 community: @current_community)
      else
        Result::Success.new()
      end
    }
    email_check = ->(_) {
      if @current_user.has_valid_email_for_community?(@current_community)
        Result::Success.new()
      else
        validate_email(address: values[:email],
                       community: @current_community,
                       user: @current_user)
      end
    }
    terms_check = ->(_, _) {
      validate_terms(consent: values[:consent], community: @current_community)
    }

    check_result = Result.all(invitation_check, email_check, terms_check)

    check_result.and_then { |invitation_code, email_address, consent|
      update_membership!(membership: membership,
                         invitation_code: invitation_code,
                         email_address: email_address,
                         consent: consent,
                         community: @current_community,
                         user: @current_user)
    }.on_success {

      # Cleanup session
      session[:fb_join] = nil
      session[:invitation_code] = nil

      Delayed::Job.enqueue(CommunityJoinedJob.new(@current_user.id, @current_community.id))
      Delayed::Job.enqueue(SendWelcomeEmail.new(@current_user.id, @current_community.id), priority: 5)

      # Record user's email preference
      @current_user.preferences["email_from_admins"] = (params[:form][:admin_emails_consent] == "on")
      @current_user.save

      record_event(flash, "GaveConsent")

      flash[:notice] = t("layouts.notifications.you_are_now_member")

      if session[:return_to]
        redirect_to session[:return_to]
        session[:return_to] = nil
      else
        redirect_to search_path
      end

    }.on_error { |msg, data|

      case data[:reason]

      when :invitation_code_invalid_or_used
        flash[:error] = t("community_memberships.give_consent.invitation_code_invalid_or_used")
        logger.info("Invitation code was invalid or used", :membership_email_not_allowed, data)
        render_pending_consent_form(values.except(:invitation_code))

      when :email_not_allowed
        flash[:error] = t("community_memberships.give_consent.email_not_allowed")
        logger.info("Email is not allowed", :membership_email_not_allowed, data)
        render_pending_consent_form(values.except(:email))

      when :email_not_available
        flash[:error] = t("community_memberships.give_consent.email_not_available")
        logger.info("Email is not available", :membership_email_not_available, data)
        render_pending_consent_form(values.except(:email))

      when :consent_not_given
        flash[:error] = t("community_memberships.give_consent.consent_not_given")
        logger.info("Terms were not accepted", :membership_consent_not_given, data)
        render_pending_consent_form(values.except(:consent))

      when :update_failed
        flash[:error] = t("layouts.notifications.joining_community_failed")
        logger.info("Membership update failed", :membership_update_failed, data)
        render_pending_consent_form(values)

      else
        raise ArgumentError.new("Unhandled error case: #{data[:reason]}")
      end
    }
  end

  def confirmation_pending
    render :confirmation_pending, locals: {support_email: APP_CONFIG.support_email}
  end

  # Ajax end-points for front-end validation

  def check_email_availability_and_validity
    values = Form.call(params[:form])
    validation_result = validate_email(address: values[:email],
                                       user: @current_user,
                                       community: @current_community)

    render json: validation_result.success
  end

  def check_invitation_code
    values = Form.call(params[:form])
    validation_result = validate_invitation_code(invitation_code: values[:invitation_code],
                                                 community: @current_community)

    render json: validation_result.success
  end

  def access_denied
    # Nothing here, just render the access_denied.haml
  end

  private

  def render_pending_consent_form(form_values = {})
    @service = Person::SettingsService.new(community: @current_community, params: params,
                                           required_fields_only: true, person: @current_user)
    values = Form.call(form_values)
    invite_only = @current_community.join_with_invite_only?
    allowed_emails = Maybe(@current_community.allowed_emails).split(",").or_else([])

    render :pending_consent, locals: {
             invite_only: invite_only,
             allowed_emails: allowed_emails,
             has_valid_email_for_community: @current_user.has_valid_email_for_community?(@current_community),
             values: values
           }
  end

  def validate_email(address:, community:, user:)
    if !community.email_allowed?(address)
      Result::Error.new("Email is not allowed", reason: :email_not_allowed, email: address)
    elsif !Email.email_available?(address, community.id)
      Result::Error.new("Email is not available", reason: :email_not_available, email: address)
    else
      Result::Success.new(address)
    end
  end

  def validate_invitation_code(invitation_code:, community:)
    if !Invitation.code_usable?(invitation_code, community)
      Result::Error.new("Invitation code is not usable", reason: :invitation_code_invalid_or_used, invitation_code: invitation_code)
    else
      Result::Success.new(invitation_code.upcase)
    end
  end

  def validate_terms(consent:, community:)
    if consent == "on"
      Result::Success.new(community.consent)
    else
      Result::Error.new("Consent not accepted", reason: :consent_not_given)
    end
  end

  def update_membership!(membership:, invitation_code:, email_address:, consent:, user:, community:)
    make_admin = community.members.count == 0 # First member is the admin

    begin
      ActiveRecord::Base.transaction do
        if email_address.present?
          Email.create!(person_id: user.id, address: email_address, community_id: community.id)
        end

        m_invitation = Maybe(invitation_code).map { |code| Invitation.find_by(code: code) }
        m_invitation.each { |invitation|
          invitation.use_once!
        }

        attrs = {
          consent: consent,
          invitation: m_invitation.or_else(nil),
          status: "accepted"
        }

        attrs[:admin] = true if make_admin

        membership.update_attributes!(attrs)
        update_person_custom_fields(user)
      end

      Result::Success.new(membership)
    rescue
      errors = "#{membership.errors.full_messages} #{user.errors.full_messages}"
      Result::Error.new("Updating membership failed", reason: :update_failed, errors: errors)
    end
  end

  def report_missing_membership(user, community)
    ArgumentError.new("User doesn't have membership. Don't know how to continue. person_id: #{user.id}, community_id: #{community.id}")
  end

  def membership
    @membership ||= @current_user.community_membership
  end

  # Filters

  def ensure_membership_found
    report_missing_membership(@current_user, @current_community) if membership.nil?
  end

  def ensure_membership_is_not_accepted
    if membership.accepted?
      flash[:notice] = t("layouts.notifications.you_are_already_member")
      redirect_to search_path
    end
  end

  def ensure_membership_status(status)
    raise ArgumentError.new("Unknown state #{status}") unless CommunityMembership::VALID_STATUSES.include?(status)

    if membership.status != status
      redirect_to search_path
    end
  end

  def update_person_custom_fields(person)
    if params[:person].try(:[], :custom_field_values_attributes)
      person.update_attributes!(person_params)
    end
  end

  def person_params
    params.require(:person)
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
  end
end
