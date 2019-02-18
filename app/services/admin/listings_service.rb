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
    listing.update_column(:approval, params[:listing][:approval]) # rubocop:disable Rails/SkipsModelValidations
  end

  private

  def resource_scope
    community.listings
  end
end
