module Admin2::Emails
  class NewslettersController < Admin2::AdminBaseController

    def index; end

    def update_newsletter
      @current_community.update!(newsletters_params)
      flash[:notice] = t('admin2.notifications.newsletters_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_emails_newsletters_path
    end

    private

    def newsletters_params
      params.require(:community).permit(:automatic_newsletters,
                                        :default_min_days_between_community_updates)
    end
  end
end
