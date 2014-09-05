#
# Give `listing`, `community` and `user` and get back true or false
# whether of not the listing can be shown to given user in the given community
#
class ListingVisibilityGuard

  def initialize(listing, community, user)
    @listing = listing
    @community = community
    @user = user
  end

  def visible?
     authorized_to_view? && (open? || is_author?)
  end

  def authorized_to_view?
    return false unless listing_belongs_to_community?

    if user_logged_in? && user_member_of_community?
      true
    else
      public_listing? && public_community?
    end
  end

  private

  def open?
    !@listing.closed?
  end

  def listing_belongs_to_community?
    @community && @listing.communities.include?(@community)
  end

  def user_logged_in?
    !@user.nil?
  end

  def user_member_of_community?
    @user.communities.include?(@community)
  end

  def public_listing?
    @listing.privacy == "public"
  end

  def public_community?
    !@community.private?
  end

  def is_author?
    @user == @listing.author
  end
end
