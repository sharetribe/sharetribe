module Admin2::Emails
  class EmailUsersController < Admin2::AdminBaseController

    def index; end

    def create
      content = params[:email][:content].gsub(/[”“]/, '"')
      if params[:test_email] == '1'
        Delayed::Job.enqueue(CommunityMemberEmailSentJob.new(@current_user.id,
                                                             @current_user.id,
                                                             @current_community.id,
                                                             content,
                                                             params[:email][:locale], true))
        flash[:notice] = t('admin2.notifications.test_email_sent')
      else
        email_job = CreateMemberEmailBatchJob.new(@current_user.id,
                                                  @current_community.id,
                                                  content,
                                                  params[:email][:locale],
                                                  params[:email][:recipients])
        Delayed::Job.enqueue(email_job)
        flash[:notice] = t('admin2.notifications.email_sent')
      end
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_emails_email_users_path
    end
  end
end
