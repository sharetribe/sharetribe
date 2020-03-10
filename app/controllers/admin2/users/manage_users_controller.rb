module Admin2::Users
  class ManageUsersController < Admin2::AdminBaseController
    before_action :set_service

    def index
      respond_to do |format|
        format.html {}
        format.csv do
          self.response.headers['Content-Type'] ||= 'text/csv'
          self.response.headers['Content-Disposition'] = "attachment; filename=#{marketplace_name}-users-#{Time.zone.today}.csv"
          self.response.headers['Content-Transfer-Encoding'] = 'binary'
          self.response.headers['Last-Modified'] = Time.current.ctime.to_s
          self.response_body = @service.memberships_csv
        end
      end
    end

    def resend_confirmation
      @service.resend_confirmation
      render layout: false
    end

    def ban
      if @service.membership_current_user?
        raise t('admin2.manage_users.ban_me_error')
      end

      @service.ban
      @can_delete = @presenter.can_delete(@service.membership)
      @delete_title = @presenter.delete_member_title(@service.membership).to_s.html_safe # rubocop:disable Rails/OutputSafety
    rescue StandardError => e
      @error = e.message
    ensure
      render layout: false
    end

    def promote_admin
      if @service.removes_itself?
        raise t('admin2.manage_users.cannot_delete_yourself_admin')
      end

      @service.promote_admin
    rescue StandardError => e
      @error = e.message
    ensure
      render layout: false
    end

    def posting_allowed
      @service.posting_allowed
      @id = params[:id]
      @allow_id = params[:allowed_to_post].present?
      @disallow_id = params[:disallowed_to_post].present?
    rescue StandardError => e
      @error = e.message
    ensure
      render layout: false
    end

    def unban
      @service.unban
      @can_delete = @presenter.can_delete(@service.membership)
      @delete_title = @presenter.delete_member_title(@service.membership).to_s.html_safe # rubocop:disable Rails/OutputSafety
    rescue StandardError => e
      @error = e.message
    ensure
      render layout: false
    end

    def destroy
      @service.destroy
      @error = @service.error_message
    rescue StandardError => e
      @error = e.message
    ensure
      render layout: false
    end

    private

    def marketplace_name
      if @current_community.use_domain
        @current_community.domain
      else
        @current_community.ident
      end
    end

    def set_service
      @service = Admin2::MembershipService.new(
        community: @current_community,
        params: params,
        current_user: @current_user)

      @presenter = Admin2::MembershipPresenter.new(
        service: @service,
        params: params)
    end

  end
end
