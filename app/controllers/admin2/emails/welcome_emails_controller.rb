module Admin2::Emails
  class WelcomeEmailsController < Admin2::AdminBaseController

    def index; end

    def update_email
      @current_community.update!(email_params)
      if params[:test_email] == '1'
        MailCarrier.deliver_later(PersonMailer.welcome_email(@current_user, @current_community, true, true))
        flash[:notice] = t('admin2.notifications.welcome_email_updated_and_sent', email: @current_user.confirmed_notification_emails_to)
      else
        flash[:notice] = t('admin2.notifications.welcome_email_updated')
      end
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_emails_welcome_emails_path
    end

    private

    def email_params
      params.require(:community).permit(community_customizations_attributes: %i[id welcome_email_content])
    end
  end
end
