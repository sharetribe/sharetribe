class ConfirmationsController < Devise::ConfirmationsController

  skip_before_action :cannot_access_if_banned,
              :cannot_access_without_confirmation,
              :ensure_consent_given,
              :ensure_user_belongs_to_community

  before_action(only: [:create]) do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_this_page")
  end

  # This is overridden from Devise::ConfirmationsController
  # to be able to handle better the situations of resending confirmation and
  # confirmation attemt with wrong token.

  # POST /resource/confirmation
  def create
    email = params.dig(:person, :email)
    to_confirm = create_or_find_email(email)

    if to_confirm
      Email.send_confirmation(to_confirm, @current_community)
      flash[:notice] = t("sessions.confirmation_pending.check_your_email")
      redirect_to confirmation_pending_path
    else
      redirect_to search_path
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    if params[:confirmation_token]
      #sometimes tests catch extra ' char with link, so remove it if there
      params[:confirmation_token] = params[:confirmation_token].chomp("'")
    end

    #check if this confirmation code matches to additional emails
    e = Email.find_by_confirmation_token(params[:confirmation_token])
    if e
      person = e.person
      e.confirmed_at = Time.now
      e.confirmation_token = nil
      e.save

      # Accept pending community membership if needed
      if @current_community.approve_pending_membership(person, e.address)
        # If the pending membership was accepted now, it's time to send the welcome email, unless creating admin acocunt
        Delayed::Job.enqueue(SendWelcomeEmail.new(person.id, @current_community.id), priority: 5)
      end
      flash[:notice] = t("layouts.notifications.additional_email_confirmed")

      record_event(flash, "AccountConfirmed")

      if @current_user && @current_user.has_admin_rights?(@current_community)
        record_event(flash, "admin_email_confirmed")
        redirect_to admin_getting_started_guide_path and return
      elsif @current_user # normal logged in user
        if session[:return_to]
          redirect_to session[:return_to]
          session[:return_to] = nil
        else
          redirect_to search_path
        end

        return
      else # no logged in session
        redirect_to login_path and return
      end
    end

    flash[:error] = t("layouts.notifications.confirmation_link_is_wrong_or_used")
    if @current_user
      redirect_to confirmation_pending_path
    else
      redirect_to search_path
    end
  end

  private

  def create_or_find_email(email)
    if new_email_address_sent?(email)
      # If user submitted the email change form, change the email before sending again.
      create_new_email(email)
    else
      email_to_confirm = @current_user.latest_pending_email_address(@current_community)
      Email.find_by_address_and_community_id(email_to_confirm, @current_community.id)
    end
  end

  def create_new_email(email)
    if !@current_community.email_allowed?(email)
      flash[:error] = t("people.new.email_not_allowed")
    elsif !Email.email_available?(email, @current_community.id)
      flash[:error] = t("people.new.email_is_in_use")
    else
      Email.create(:person => @current_user, :address => email, :send_notifications => true, community_id: @current_community.id)
    end
  end

  def new_email_address_sent?(email)
    email && !@current_user.has_email?(email)
  end
end
