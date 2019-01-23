class Admin::MembershipPresenter
  include Collator

  private

  attr_reader :service, :params

  public

  delegate :memberships, :community, to: :service, prefix: false, allow_nil: false

  def initialize(service:, params:)
    @service = service
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

  def person_name(person)
    display_name = person.display_name.present? ? " (#{person.display_name})" : ''
    "#{person.given_name} #{person.family_name}#{display_name}"
  end

  def can_post_listing(membership)
    ready = !(membership.pending_consent? || membership.pending_email_confirmation?)
    if require_verification_to_post_listings
      membership.can_post_listings && ready
    else
      ready
    end
  end

  def require_verification_to_post_listings
    community.require_verification_to_post_listings
  end
end
