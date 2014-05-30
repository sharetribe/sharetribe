class PageLoadedJob < Struct.new(:community_membership_id, :host)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # No need to set the mailer as no mails sent from this action
    # ApplicationHelper.store_community_service_name_to_thread_from_host(host)
  end

  def perform
    membership = CommunityMembership.find(community_membership_id)
    unless membership.last_page_load_date && membership.last_page_load_date.to_date.eql?(Date.today)
      membership.update_attribute(:last_page_load_date, DateTime.now)
      # FIXME: Day counting and badge check disabled as it produced too big numbers for unknown reason
      #current_user.active_days_count += 1
    end
  end

end
