require 'csv'

class Admin::CommunityMembershipsController < ApplicationController
  before_filter :ensure_is_admin

  def index
    @selected_left_navi_link = "manage_members"
    @community = @current_community

    respond_to do |format|
      format.html do
        @memberships = CommunityMembership.where(:community_id => @current_community.id, :status => "accepted")
                                           .includes(:person => :emails)
                                           .paginate(:page => params[:page], :per_page => 50)
                                           .order("#{sort_column} #{sort_direction}")
      end
      with_feature(:export_users_as_csv) do
        format.csv do
          all_memberships = CommunityMembership.where(:community_id => @community.id)
                                                .where("status != 'deleted_user'")
                                                .includes(:person => :emails)
                                                .order("created_at ASC")
          marketplace_name = if @community.use_domain
            @community.domain
          else
            @community.ident
          end
          send_data generate_csv_for(all_memberships), filename: "#{marketplace_name}-users-#{Date.today}.csv"
        end
      end
    end
  end

  def ban
    membership = CommunityMembership.find_by_id(params[:id])

    if membership.person == @current_user
      flash[:error] = t("admin.communities.manage_members.ban_me_error")
      return redirect_to admin_community_community_memberships_path(@current_community)
    end

    membership.update_attributes(:status => "banned")
    membership.update_attributes(:admin => 0) if membership.admin == 1

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

  def generate_csv_for(memberships)
    CSV.generate(headers: true, force_quotes: true) do |csv|
      # first line is column names
      header_row = %w{
        first_name
        last_name
        username
        email_address
        email_address_confirmed
        joined_at
        status
        is_admin
        accept_emails_from_admin
      }
      community_requires_verification_to_post =
        memberships.first && memberships.first.community.require_verification_to_post_listings
      header_row.push("can_post_listings") if community_requires_verification_to_post
      csv << header_row
      memberships.each do |membership|
        user = membership.person
        unless user.blank?
          user_data = [
            user.given_name,
            user.family_name,
            user.username,
            membership.created_at,
            membership.status,
            membership.admin
          ]
          user_data.push(membership.can_post_listings) if community_requires_verification_to_post
          user.emails.each do |email|
            accept_emails_from_admin = user.preferences["email_from_admins"] && email.send_notifications
            csv << user_data.clone.insert(3, email.address, !!email.confirmed_at).insert(8, accept_emails_from_admin)
          end
        end
      end
    end
  end

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
