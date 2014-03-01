class Admin::CommunitiesController < ApplicationController
  
  include CommunitiesHelper
  
  before_filter :ensure_is_admin
  
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
    @members = @current_community.members.paginate(:page => params[:page], :per_page => 50).order("created_at desc")
  end

  def posting_allowed
    CommunityMembership.where(:person_id => params[:allowed_to_post]).update_all("can_post_listings = 1")
    CommunityMembership.where(:person_id => params[:disallowed_to_post]).update_all("can_post_listings = 0")

    render nothing: true, status: 200
  end

  def test_welcome_email
    PersonMailer.welcome_email(@current_user, @current_community, true).deliver
    flash[:notice] = t("layouts.notifications.test_welcome_email_delivered_to", :email => @current_user.email)
    redirect_to edit_welcome_email_admin_community_path(@current_community)
  end

  def settings
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "admin_settings"
  end
  
  def update
    return_to_action =  (params[:community_settings_page] == "look_and_feel" ? :edit_look_and_feel : :edit_details)
    
    @community = Community.find(params[:id])
    need_to_regenerate_css = params[:community][:custom_color1] != @community.custom_color1 || params[:community][:custom_color2] != @community.custom_color2 || params[:community][:cover_photo] || params[:community][:small_cover_photo]
    
    params[:community][:custom_color1] = nil if params[:community][:custom_color1] == ""
    params[:community][:custom_color2] = nil if params[:community][:custom_color2] == ""
    
    if @community.update_attributes(params[:community])
      flash[:notice] = t("layouts.notifications.community_updated")
      CommunityStylesheetCompiler.compile(@community) if need_to_regenerate_css
      redirect_to (return_to_action == :edit_look_and_feel ? 
                   edit_look_and_feel_admin_community_path(@community) : 
                   edit_details_admin_community_path(@community))  
    else
      flash.now[:error] = t("layouts.notifications.community_update_failed")
      render :action => return_to_action  
    end
  end

  def update_settings
    @community = Community.find(params[:id])
    if @community.update_attributes(params[:community])
      flash[:notice] = t("layouts.notifications.community_updated")
      redirect_to settings_admin_community_path(@current_community)
    else
      flash.now[:error] = t("Update failed")
      render :action => "settings"
    end
  end
  
end