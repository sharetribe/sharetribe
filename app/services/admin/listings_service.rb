class Admin::ListingsService
  attr_reader :community, :params

  def initialize(community:, params:)
    @params = params
    @community = community
  end

  def listing
    @listing ||= resource_scope.find(params[:id])
  end

  def update
    listing.update_column(:state, params[:listing][:state]) # rubocop:disable Rails/SkipsModelValidations
  end

  def approve
    listing.update_column(:state, Listing::APPROVED) # rubocop:disable Rails/SkipsModelValidations
  end

  def reject
    listing.update_column(:state, Listing::APPROVAL_REJECTED) # rubocop:disable Rails/SkipsModelValidations
  end

  private

  def resource_scope
    community.listings
  end
end
