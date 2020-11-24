class PageLoadedJob < Struct.new(:community_membership_id, :host)

  include DelayedAirbrakeNotification

  def perform
    membership = CommunityMembership.find(community_membership_id)
    unless membership.last_page_load_date && membership.last_page_load_date.to_date.eql?(Date.today)
      membership.update_attribute(:last_page_load_date, DateTime.now)
      # FIXME: Day counting and badge check disabled as it produced too big numbers for unknown reason
      #current_user.active_days_count += 1
    end
  end

end
