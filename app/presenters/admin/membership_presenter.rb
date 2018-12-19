class Admin::MembershipPresenter
  include Collator

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def selected_statuses_title
    if params[:status].present?
      I18n.t("admin.communities.manage_members.status_filter.selected", count: params[:status].size)
    else
      I18n.t("admin.communities.manage_members.status_filter.all")
    end
  end

  FILTER_STATUSES = ['admin', 'banned', 'posting_allowed', 'accepted', 'unconfirmed', 'pending']

  def sorted_statuses
    FILTER_STATUSES.map {|status|
      [status, I18n.t("admin.communities.manage_members.status_filter.#{status}"), status_checked?(status)]
    }.sort_by{|status, translation, checked| collator.get_sort_key(translation) }
  end

  def status_checked?(status)
    params[:status].present? && params[:status].include?(status)
  end
end
