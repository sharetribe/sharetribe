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
        render json: { message: t('admin2.notifications.test_email_sent') }
      else
        email_job = CreateMemberEmailBatchJob.new(@current_user.id,
                                                  @current_community.id,
                                                  content,
                                                  params[:email][:locale],
                                                  params[:email][:recipients])
        Delayed::Job.enqueue(email_job)
        render json: { message: t('admin2.notifications.email_sent') }
      end
    rescue StandardError => e
      render json: { message: e.message }, status: 422
    end
  end
end
