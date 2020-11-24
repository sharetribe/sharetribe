require 'csv'

class Admin::CommunityMembershipsController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service

  def index
    respond_to do |format|
      format.html {}
      format.csv do
        marketplace_name = if @current_community.use_domain
          @current_community.domain
        else
          @current_community.ident
        end

        self.response.headers["Content-Type"] ||= 'text/csv'
        self.response.headers["Content-Disposition"] = "attachment; filename=#{marketplace_name}-users-#{Date.today}.csv"
        self.response.headers["Content-Transfer-Encoding"] = "binary"
        self.response.headers["Last-Modified"] = Time.now.ctime.to_s

        self.response_body = @service.memberships_csv
      end
    end
  end

  def ban
    if @service.membership_current_user?
      flash[:error] = t("admin.communities.manage_members.ban_me_error")
      return redirect_to admin_community_community_memberships_path(@current_community)
    end

    membership = @service.ban

    if request.xhr?
      render json: {status: membership.status}
    else
      redirect_to admin_community_community_memberships_path(@current_community)
    end
  end

  def unban
    membership = @service.unban
    if request.xhr?
      render json: {status: membership.status}
    else
      redirect_to admin_community_community_memberships_path(@current_community)
    end
  end

  def promote_admin
    if @service.removes_itself?
      render body: nil, status: :method_not_allowed
    else
      @service.promote_admin
      render body: nil, status: :ok
    end
  end

  def posting_allowed
    @service.posting_allowed
    render body: nil, status: :ok
  end

  def resend_confirmation
    @service.resend_confirmation
    render body: nil, status: :ok
  end

  def destroy
    @service.destroy
    flash[:error] = @service.error_message
    redirect_to admin_community_community_memberships_path(@current_community)
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = 'manage_members'
  end

  def set_service
    @service = Admin::Communities::MembershipService.new(
      community: @current_community,
      params: params,
      current_user: @current_user)
    @presenter = Admin::MembershipPresenter.new(
      service: @service,
      params: params)
  end
end
