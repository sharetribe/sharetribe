require 'csv'

class Admin::CommunityMembershipsController < Admin::AdminBaseController

  def index
    @selected_left_navi_link = "manage_members"
    @community = @current_community

    respond_to do |format|
      format.html do
        @memberships = CommunityMembership.where(community_id: @current_community.id, status: ["accepted", "banned"])
                                           .includes(person: :emails)
                                           .paginate(page: params[:page], per_page: 50)
                                           .order("#{sort_column} #{sort_direction}")
        if params[:q].present?
          query = <<-SQL
          community_memberships.person_id IN
          (SELECT p.id FROM people p LEFT OUTER JOIN emails e ON e.person_id = p.id
           WHERE p.given_name like ? OR p.family_name like ? OR p.display_name like ? OR e.address like ?)
          SQL
          like_q = "%#{params[:q]}%"
          @memberships = @memberships.where(query, like_q, like_q, like_q, like_q)
        end
      end
      format.csv do
        all_memberships = CommunityMembership.where(community_id: @community.id)
                                              .where("status != 'deleted_user'")
                                              .includes(person: [:emails, :location])
        marketplace_name = if @community.use_domain
          @community.domain
        else
          @community.ident
        end

        self.response.headers["Content-Type"] ||= 'text/csv'
        self.response.headers["Content-Disposition"] = "attachment; filename=#{marketplace_name}-users-#{Date.today}.csv"
        self.response.headers["Content-Transfer-Encoding"] = "binary"
        self.response.headers["Last-Modified"] = Time.now.ctime.to_s

        self.response_body = Enumerator.new do |yielder|
          generate_csv_for(yielder, all_memberships, @community)
        end
      end
    end
  end

  def ban
    membership = CommunityMembership.find_by(id: params[:id], community_id: @current_community.id)

    if membership.person == @current_user
      flash[:error] = t("admin.communities.manage_members.ban_me_error")
      return redirect_to admin_community_community_memberships_path(@current_community)
    end

    membership.update_attributes(status: "banned")
    membership.update_attributes(admin: 0) if membership.admin == 1

    @current_community.close_listings_by_author(membership.person)

    if request.xhr?
      render json: {status: membership.status}
    else
      redirect_to admin_community_community_memberships_path(@current_community)
    end
  end

  def unban
    membership = CommunityMembership.find_by(id: params[:id], community_id: @current_community.id)
    membership.update_attributes(status: "accepted")
    if request.xhr?
      render json: {status: membership.status}
    else
      redirect_to admin_community_community_memberships_path(@current_community)
    end
  end

  def promote_admin
    if removes_itself?(params[:remove_admin], @current_user)
      render body: nil, status: 405
    else
      @current_community.community_memberships.where(person_id: params[:add_admin]).update_all("admin = 1")
      @current_community.community_memberships.where(person_id: params[:remove_admin]).update_all("admin = 0")

      render body: nil, status: 200
    end
  end

  def posting_allowed
    @current_community.community_memberships.where(person_id: params[:allowed_to_post]).update_all("can_post_listings = 1")
    @current_community.community_memberships.where(person_id: params[:disallowed_to_post]).update_all("can_post_listings = 0")

    render body: nil, status: 200
  end

  private

  def generate_csv_for(yielder, memberships, community)
    # first line is column names
    header_row = %w{
      first_name
      last_name
      display_name
      username
      phone_number
      address
      email_address
      email_address_confirmed
      joined_at
      status
      is_admin
      accept_emails_from_admin
      language
    }
    header_row.push("can_post_listings") if community.require_verification_to_post_listings
    header_row += community.person_custom_fields.map{|f| f.name}
    yielder << header_row.to_csv(force_quotes: true)
    memberships.find_each do |membership|
      user = membership.person
      unless user.blank?
        user_data = {
          first_name: user.given_name,
          last_name: user.family_name,
          display_name: user.display_name,
          username: user.username,
          phone_number: user.phone_number,
          address: user.location ? user.location.address : "",
          email_address: nil,
          email_address_confirmed: nil,
          joined_at: membership.created_at,
          status: membership.status,
          is_admin: membership.admin,
          accept_emails_from_admin: nil,
          language: user.locale
        }
        user_data[:can_post_listings] = membership.can_post_listings if community.require_verification_to_post_listings
        community.person_custom_fields.each do |field|
          field_value = user.custom_field_values.by_question(field).first
          user_data[field.name] = field_value.try(:display_value)
        end
        user.emails.each do |email|
          accept_emails_from_admin = user.preferences["email_from_admins"] && email.send_notifications
          data = user_data.clone
          data[:email_address] = email.address
          data[:email_address_confirmed] = !!email.confirmed_at
          data[:accept_emails_from_admin] = !!accept_emails_from_admin
          yielder << data.values.to_csv(force_quotes: true)
        end
      end
    end
  end

  def removes_itself?(ids, current_admin_user)
    ids ||= []
    ids.include?(current_admin_user.id) && current_admin_user.is_marketplace_admin?(@current_community)
  end

  def sort_column
    case params[:sort]
    when "name"
      "people.given_name"
    when "display_name"
      "people.display_name"
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
    if params[:direction] == "asc"
      "asc"
    else
      "desc" #default
    end
  end
end
