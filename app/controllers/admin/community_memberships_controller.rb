class Admin::CommunityMembershipsController < ApplicationController
  before_filter :ensure_is_admin
  skip_filter :dashboard_only

  def index
    @selected_left_navi_link = "manage_members"
    @community = @current_community
    @memberships = CommunityMembership.where(:community_id => @current_community.id, :status => "accepted")
                                       .includes(:person => :emails)
                                       .paginate(:page => params[:page], :per_page => 50)
                                       .order("#{sort_column} #{sort_direction}")
  end

  def ban
    membership = CommunityMembership.find_by_id(params[:id])
    membership.update_attributes(:status => "banned")

    @current_community.close_listings_by_author(membership.person)

    redirect_to admin_community_community_memberships_path(@current_community)
  end

  def promote_admin
    if removes_itself?(params[:remove_admin], @current_user, @current_community)
      render nothing: true, status: 405
    else
      @current_community.community_memberships.where(:person_id => params[:add_admin]).update_all("admin = 1")
      @current_community.community_memberships.where(:person_id => params[:remove_admin]).update_all("admin = 0")

      render nothing: true, status: 200
    end
  end

  def posting_allowed
    @current_community.community_memberships.where(:person_id => params[:allowed_to_post]).update_all("can_post_listings = 1")
    @current_community.community_memberships.where(:person_id => params[:disallowed_to_post]).update_all("can_post_listings = 0")

    render nothing: true, status: 200
  end

  private

  def removes_itself?(ids, current_admin_user, community)
    ids ||= []
    ids.include?(current_admin_user.id) && current_admin_user.is_admin_of?(community)
  end

  def sort_column
    case params[:sort]
    when "name"
      "people.given_name"
    when "email"
      "emails.address"
    when "join_date"
      "created_at"
    when "posting_allowed"
      "can_post_listings"
    else
      "created_at"
    end
  end

  def sort_direction
    #prevents sql injection
    if params[:direction] == "asc"
      "asc"
    else
      "desc" #default
    end
  end

end
