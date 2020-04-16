module Admin2::Listings
  class ManageListingsController < Admin2::AdminBaseController
    before_action :set_service

    def index; end

    def update
      @status = @service.update
      render layout: false
    end

    def close
      @service.close
      render layout: false
    end

    def delete
      @service.delete
    rescue StandardError => e
      @error = e.message
    ensure
      render layout: false
    end

    def export
      @export_result = ExportTaskResult.create
      Delayed::Job.enqueue(ExportListingsJob.new(@current_user.id, @current_community.id, @export_result.id))
      render layout: false
    end

    def export_status
      export_result = ExportTaskResult.find_by(token: params[:token])
      if export_result
        file_url = export_result.file.present? ? export_result.file.expiring_url(ExportTaskResult::AWS_S3_URL_EXPIRES_SECONDS) : nil
        render json: { token: export_result.token, status: export_result.status, url: file_url }
      else
        render json: { status: 'error' }
      end
    end

    private

    def set_service
      @service = Admin2::ListingsService.new(
        community: @current_community,
        params: params)
      @presenter = Listing::ListPresenter.new(@current_community,
                                              @current_user, params,
                                              true, 100)
    end
  end
end
