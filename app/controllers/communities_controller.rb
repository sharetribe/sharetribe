class CommunitiesController < ApplicationController
  
  include CommunitiesHelper
  
  layout 'dashboard'
  
  skip_filter :single_community_only
  
  before_filter :only => [ :set_organization_email ] do |controller|
    controller.ensure_logged_in "you_must_log_in_to_view_this_content"
  end
  
  respond_to :html, :json
  
  def index
    @communities = Community.joins(:location).select("communities.id, name, settings, domain, members_count, latitude, longitude")
    respond_with(@communities) do |format|
      format.json { render :json => { :data => @communities } }
      format.html #show the communities map
    end
  end

  def show
    @community = Community.find(params[:id])
    render :partial => "map_bubble"
  end

  def new
    @community = Community.new
    @community.community_memberships.build
    unless @community.location
      @community.build_location(:address => @community.address, :location_type => 'community')
      @community.location.search_and_fill_latlng
    end
    @person = Person.new
    session[:community_category] = params[:category] if params[:category]
    session[:pricing_plan] = params[:pricing_plan] if params[:pricing_plan]
    session[:community_locale] = params[:community_locale] if params[:community_locale]
    
    session[:confirmed_email] = session[:unconfirmed_email] if session[:unconfirmed_email] && @current_user && @current_user.has_confirmed_email?(session[:unconfirmed_email])
    
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def edit
    @community = Community.find(params[:id])
  end

  def create
    params[:community][:location][:address] = params[:community][:address] if params[:community][:address]
    location = Location.new(params[:community][:location])
    params[:community].delete(:location)
    params[:community].delete(:address)
    @community = Community.new(params[:community])
    @community.settings = {"locales"=>["#{params[:community_locale]}"]}
    @community.join_with_invite_only = params[:community][:join_with_invite_only].present?
    @community.email_confirmation = true
    @community.plan = session[:pricing_plan]
    @community.users_can_invite_new_users = true
    @community.use_captcha = false
    @community.save
    @community.community_memberships.first.update_attribute(:admin, true) #make creator an admin
    
    # Add his listings that have visibility in all communities to the new one
    @community.community_memberships.first.person.add_listings_visible_to_all_to(@community)
    
    location.community = @community
    location.save
    clear_session_variables
    render :action => :new
  end

  def update
    @community = Community.find(params[:id])

    respond_to do |format|
      if @community.update_attributes(params[:community])
        format.html { redirect_to(@community, :notice => 'Community was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @community.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def check_domain_availability
    respond_to do |format|
      format.json { render :json => Community.domain_available?(params[:community][:domain]) }
    end
  end
  
  def set_organization_email
    session[:allowed_email] = "@#{params[:email].split('@')[1]}"
    if @current_user.has_confirmed_email?(params[:email])
      session[:confirmed_email] = params[:email]
      session[:unconfirmed_email] = params[:email] 
      # FIXME: this is bit unlogically stored also to unconfirmed as the new.haml 
      # for community creation expects that step to be taken first. So having confirmed 
      # already is kind of rarer case, so setting both will make the logic based on the 
      # default case work in this case too.
    else
      # no confirmed allowed email found. 
      # Check if there is unconfirmed or should we add one.
      
      if @current_user.email == params[:email] # check primary email
        @current_user.send_confirmation_instructions
      else
        if @current_user.has_email?(params[:email]) #unconfirmed additional email
          e = Email.find_by_address(params[:email])
        else
          e = Email.create(:person => @current_user, :address => params[:email])
        end
    
        # Send confirmation for additional email
        PersonMailer.additional_email_confirmation(e, request.host_with_port).deliver
        e.confirmation_sent_at = Time.now
        e.save
      end
      session[:unconfirmed_email] = params[:email]
    end
    redirect_to new_tribe_path
  end
  
end
