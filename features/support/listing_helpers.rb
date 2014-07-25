module ListingHelpers

  def create_listing_to_current_community(opts = {})
    @listing = FactoryGirl.create(:listing, opts.merge(communities: [@current_community]))
  end

end

World(ListingHelpers)
