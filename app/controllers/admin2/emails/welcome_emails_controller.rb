module Admin2::Emails
  class WelcomeEmailsController < Admin2::AdminBaseController

    def index; end

    def update_email
      if params[:test_email] == '1'
        MailCarrier.deliver_later(PersonMailer.welcome_email(@current_user, @current_community, true, true))
        render json: { message: t('admin2.notifications.welcome_email_updated_and_sent', email: @current_user.confirmed_notification_emails_to) }
      else
        render json: { message: t('admin2.notifications.welcome_email_updated') }
      end
    rescue StandardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end
  end
end
