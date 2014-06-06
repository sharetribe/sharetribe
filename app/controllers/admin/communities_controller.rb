class Admin::CommunitiesController < ApplicationController
  helper_method :member_sort_column, :member_sort_direction

  include CommunitiesHelper

  before_filter :ensure_is_admin
  before_filter :ensure_is_superadmin, :only => [:payment_gateways, :update_payment_gateway, :create_payment_gateway]

  skip_filter :dashboard_only

  def edit_details
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "tribe_details"
    @community = @current_community
  end

  def edit_look_and_feel
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "tribe_look_and_feel"
    @community = @current_community
  end

  def edit_welcome_email
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "welcome_email"
    @community = @current_community
    @recipient = @current_user
    @url_params = {
      :host => @current_community.full_domain,
      :ref => "welcome_email",
      :locale => @current_user.locale
    }
  end

  def manage_members
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "manage_members"
    @community = @current_community
    @memberships = CommunityMembership.where(:community_id => @current_community.id, :status => "accepted")
                                       .includes(:person => :emails)
                                       .paginate(:page => params[:page], :per_page => 50)
                                       .order("#{member_sort_column} #{member_sort_direction}")
  end

  def integrations
    redirect_to edit_details_admin_community_path(@current_community) unless @current_community.integrations_in_use?
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "integrations"
    @community = @current_community
  end

  def menu_links
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "menu_links"
    @community = @current_community
  end

  def update_menu_links
    @community = @current_community

    update(@community,
            Maybe(params)[:menu_links].or_else({menu_link_attributes: {}}),
            menu_links_admin_community_path(@community),
            :menu_links)
  end

  # This is currently only for superadmins, quick and hack solution
  def payment_gateways
    # Redirect if payment gateway in use but it's not braintree
    redirect_to edit_details_admin_community_path(@current_community) if @current_community.payment_gateway && !@current_community.braintree_in_use?

    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "payment_gateways"
    @community = @current_community
    @payment_gateway = Maybe(@current_community).payment_gateway.or_else { BraintreePaymentGateway.new }

    render :braintree_payment_gateway
  end

  def update_payment_gateway
    # Redirect if payment gateway in use but it's not braintree
    redirect_to edit_details_admin_community_path(@current_community) if @current_community.payment_gateway && !@current_community.braintree_in_use?

    update(@current_community.payment_gateway,
      params[:braintree_payment_gateway],
      payment_gateways_admin_community_path(@current_community),
      :payment_gateways)
  end

  def create_payment_gateway
    @current_community.payment_gateway = BraintreePaymentGateway.create(params[:braintree_payment_gateway].merge(community: @current_community))
    update_payment_gateway
  end

  def posting_allowed
    CommunityMembership.where(:person_id => params[:allowed_to_post]).update_all("can_post_listings = 1")
    CommunityMembership.where(:person_id => params[:disallowed_to_post]).update_all("can_post_listings = 0")

    render nothing: true, status: 200
  end

  def promote_admin
    if removes_itself?(params[:remove_admin], @current_user, @current_community)
      render nothing: true, status: 405
    else
      CommunityMembership.where(:person_id => params[:add_admin]).update_all("admin = 1")
      CommunityMembership.where(:person_id => params[:remove_admin]).update_all("admin = 0")

      render nothing: true, status: 200
    end
  end

  def test_welcome_email
    PersonMailer.welcome_email(@current_user, @current_community, true).deliver
    flash[:notice] = t("layouts.notifications.test_welcome_email_delivered_to", :email => @current_user.confirmed_notification_email_to)
    redirect_to edit_welcome_email_admin_community_path(@current_community)
  end

  def settings
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "admin_settings"
  end

  def update_look_and_feel
    params[:community][:custom_color1] = nil if params[:community][:custom_color1] == ""
    params[:community][:custom_color2] = nil if params[:community][:custom_color2] == ""
    
    permitted_params = [ 
      :cover_photo, :small_cover_photo, :favicon, :custom_color1,
      :custom_color2, :default_browse_view, :name_display_type
    ]
    permitted_params << :custom_head_script if @current_community.custom_head_script_in_use?
    params.require(:community).permit(*permitted_params)
    
    needs_stylesheet_recompile = regenerate_css?(params, @current_community)
    update(@current_community,
           params[:community],
           edit_look_and_feel_admin_community_path(@current_community),
           :edit_look_and_feel) {
      CommunityStylesheetCompiler.compile(@current_community) if needs_stylesheet_recompile
    }
  end

  def update_integrations
    @community = Community.find(params[:id])
    [:twitter_handle,
     :google_analytics_key,
     :facebook_connect_id,
     :facebook_connect_secret].each do |param|
      params[:community][param] = nil if params[:community][param] == ""
    end

    update(@community,
            params[:community],
            integrations_admin_community_path(@community),
            :integrations)
  end

  def update_settings
    update(@current_community,
            params[:community],
            settings_admin_community_path(@current_community),
            :settings)
  end

  def removes_itself?(ids, current_admin_user, community)
    ids ||= []
    ids.include?(current_admin_user.id) && current_admin_user.is_admin_of?(community)
  end

  private

  def member_sort_column
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

  def member_sort_direction
    params[:direction] || "desc"
  end

  def regenerate_css?(params, community)
    params[:community][:custom_color1] != community.custom_color1 ||
    params[:community][:custom_color2] != community.custom_color2 ||
    params[:community][:cover_photo] ||
    params[:community][:small_cover_photo] ||
    params[:community][:wide_logo] ||
    params[:community][:logo]
  end

  def update(model, params, path, action, &block)
    Rails.logger.debug "update"
    if model.update_attributes(params)
      Rails.logger.debug "success"
      flash[:notice] = t("layouts.notifications.community_updated")
      yield if block_given? #on success, call optional block
      redirect_to path
    else
      Rails.logger.debug "Failed"
      Rails.logger.debug model.errors.full_messages
      flash.now[:error] = t("layouts.notifications.community_update_failed")
      render action
    end
  end
end
