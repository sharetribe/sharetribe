class Person::ShowService
  attr_reader :community, :params, :current_user

  def initialize(community:, params:, current_user:)
    @params = params
    @community = community
    @current_user = current_user
  end

  def person
    return @person if defined?(@person)

    person = Person.find_by!(username: params[:username], community_id: community.id)
    @person = person.deleted? || person.banned? ? nil : person
  end

  def received_testimonials
    @received_testimonials ||= person.received_testimonials.by_community(community)
  end

  def received_testimonials?
    received_testimonials.any?
  end

  def received_positive_testimonials
    @received_positive_testimonials ||= person.received_positive_testimonials.by_community(community)
  end

  def feedback_positive_percentage
    @feedback_positive_percentage ||= person.feedback_positive_percentage_in_community(community)
  end

  def community_person_custom_fields
    @community_person_custom_fields ||= community.person_custom_fields.is_public
  end

  def followed_people
    @followed_people ||= person.followed_people
  end

  def listings
    return @listings if defined?(@listings)

    include_closed = current_user == person && params[:show_closed]
    search = {
      author_id: person.id,
      include_closed: include_closed,
      page: 1,
      per_page: 6
    }

    includes = [:author, :listing_images]
    raise_errors = Rails.env.development?

    @listings =
      ListingIndexService::API::Api
      .listings
      .search(
        community_id: community.id,
        search: search,
        engine: FeatureFlagHelper.search_engine,
        raise_errors: raise_errors,
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

  def admin?
    current_user&.has_admin_rights?(community)
  end

  def can_post_listing?
    membership = person&.community_membership
    if membership
      if community.require_verification_to_post_listings
        membership.accepted? && membership.can_post_listings
      else
        membership.accepted?
      end
    end
  end
end
