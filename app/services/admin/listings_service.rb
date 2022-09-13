class Admin::ListingsService
  attr_reader :community, :params, :person

  def initialize(community:, params:, person: nil)
    @params = params
    @community = community
    @person = person
  end

  def listing
    @listing ||= resource_scope.find(params[:id])
  end

  def update
    case params[:listing][:state]
    when Listing::APPROVED
      approve
    when Listing::APPROVAL_REJECTED
      reject
    end
  end

  def approve
    listing.update_columns(state: Listing::APPROVED, # rubocop:disable Rails/SkipsModelValidations
                           approval_count: listing.approval_count + 1)
    self.class.send_listing_approved(listing.id)
    notify_followers
  end

  def reject
    listing.update_column(:state, Listing::APPROVAL_REJECTED) # rubocop:disable Rails/SkipsModelValidations
    self.class.send_listing_rejected(listing.id)
  end

  def update_by_author_params(update_listing)
    if community.pre_approved_listings? && !person.has_admin_rights?(community)
      if update_listing.approved? || update_listing.approval_rejected?
        {state: Listing::APPROVAL_PENDING}
      else
        {}
      end
    else
      {state: Listing::APPROVED}
    end
  end

  def update_by_author_successful(updated_listing)
    if updated_listing.approval_pending?
      community.admins.each do |admin|
        self.class.send_edited_listing_submited_for_review(updated_listing.id, admin.id)
      end
    end
  end

  def create_state(new_listing)
    if community.pre_approved_listings?
      unless person.has_admin_rights?(community)
        new_listing.state = Listing::APPROVAL_PENDING
      end
    end
  end

  def create_successful(new_listing)
    if new_listing.approval_pending?
      community.admins.each do |admin|
        self.class.send_listing_submited_for_review(new_listing.id, admin.id)
      end
    end
  end

  private

  def resource_scope
    community.listings
  end

  # sent only once, when the listing is approved for the first time
  def notify_followers
    if listing.approval_count == 1
      Delayed::Job.enqueue(NotifyFollowersJob.new(listing.id, community.id))
    end
  end

  class << self
    def send_listing_submited_for_review(listing_id, recipient_id)
      listing = Listing.find(listing_id)
      recipient = Person.find(recipient_id)
      ApplicationHelper.store_community_service_name_to_thread_from_community_id(listing.community_id)
      PersonMailer.listing_submited_for_review(listing, recipient).deliver_now
    end
    handle_asynchronously :send_listing_submited_for_review

    def send_listing_approved(listing_id)
      listing = Listing.find(listing_id)
      ApplicationHelper.store_community_service_name_to_thread_from_community_id(listing.community_id)
      PersonMailer.listing_approved(listing).deliver_now
    end
    handle_asynchronously :send_listing_approved

    def send_listing_rejected(listing_id)
      listing = Listing.find(listing_id)
      ApplicationHelper.store_community_service_name_to_thread_from_community_id(listing.community_id)
      PersonMailer.listing_rejected(listing).deliver_now
    end
    handle_asynchronously :send_listing_rejected

    def send_edited_listing_submited_for_review(listing_id, recipient_id)
      listing = Listing.find(listing_id)
      recipient = Person.find(recipient_id)
      ApplicationHelper.store_community_service_name_to_thread_from_community_id(listing.community_id)
      PersonMailer.edited_listing_submited_for_review(listing, recipient).deliver_now
    end
    handle_asynchronously :send_edited_listing_submited_for_review
  end
end
