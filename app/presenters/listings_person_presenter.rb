class ListingsPersonPresenter
  attr_accessor :listings, :person, :per_page
  def initialize(community, current_user, username, params)
    @person = Person.find_by!(username: username, community_id: community.id)
    # Returns the listings for one person formatted for profile page view
    @per_page = params[:per_page] || 10000 # the point is to show all here by default

    includes = [:author, :listing_images]
    include_closed = @person == current_user && params[:show_closed]
    search = {
      author_id: @person.id,
      include_closed: include_closed,
      page: 1,
      per_page: @per_page
    }

    @listings =
      ListingIndexService::API::Api
      .listings
      .search(
        community_id: community.id,
        search: search,
        engine: FeatureFlagHelper.search_engine,
        raise_errors: Rails.env.development?,
        includes: includes
      ).and_then { |res|
      Result::Success.new(
        ListingIndexViewUtils.to_struct(
        result: res,
        includes: includes,
        page: search[:page],
        per_page: search[:per_page]
      ))
      }.data
  end
end
