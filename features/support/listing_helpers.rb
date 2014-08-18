module ListingHelpers

  def create_listing_to_current_community(opts = {})
    @listing = FactoryGirl.create(:listing, opts.merge(communities: [@current_community]))
  end

  def visit_current_listing
    visit(listing_path(:id => @listing.id, :locale => "en"))
  end

end

World(ListingHelpers)
