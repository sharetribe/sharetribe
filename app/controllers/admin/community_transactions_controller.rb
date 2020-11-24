require 'csv'

class Admin::CommunityTransactionsController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_presenter, only: [:index, :show, :confirm, :cancel, :refund, :dismiss]

  def index
    respond_to do |format|
      format.html
      format.csv do
        marketplace_name = if @current_community.use_domain
          @current_community.domain
        else
          @current_community.ident
        end

        self.response.headers["Content-Type"] ||= 'text/csv'
        self.response.headers["Content-Disposition"] = "attachment; filename=#{marketplace_name}-transactions-#{Date.today}.csv"
        self.response.headers["Content-Transfer-Encoding"] = "binary"
        self.response.headers["Last-Modified"] = Time.now.ctime.to_s

        self.response_body = Enumerator.new do |yielder|
          ExportTransactionsJob.generate_csv_for(yielder, @transactions_presenter.transactions)
        end
      end
    end
  end

  def export
    @export_result = ExportTaskResult.create
    Delayed::Job.enqueue(ExportTransactionsJob.new(@current_user.id, @current_community.id, @export_result.id))
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def export_status
    export_result = ExportTaskResult.where(:token => params[:token]).first
    if export_result
      file_url = export_result.file.present? ? export_result.file.expiring_url(ExportTaskResult::AWS_S3_URL_EXPIRES_SECONDS) : nil
      render json: {token: export_result.token, status: export_result.status, url: file_url}
    else
      render json: {status: 'error'}
    end
  end

  def show; end

  def confirm
    unless @service.confirm
      flash[:error] = t("layouts.notifications.something_went_wrong")
    end
    redirect_to admin_community_transaction_path(community_id: @service.community, id: @service.transaction)
  end

  def cancel
    unless @service.cancel
      flash[:error] = t("layouts.notifications.something_went_wrong")
    end
    redirect_to admin_community_transaction_path(community_id: @service.community, id: @service.transaction)
  end

  def refund
    unless @service.refund
      flash[:error] = t("layouts.notifications.something_went_wrong")
    end
    redirect_to admin_community_transaction_path(community_id: @service.community, id: @service.transaction)
  end

  def dismiss
    unless @service.dismiss
      flash[:error] = t("layouts.notifications.something_went_wrong")
    end
    redirect_to admin_community_transaction_path(community_id: @service.community, id: @service.transaction)
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = "transactions"
  end

  def set_presenter
    @service = Admin::TransactionsService.new(@current_community, params, request.format, @current_user)
    @transactions_presenter = Admin::TransactionsPresenter.new(params, @service)
  end
end
