class OrganizationsController < ApplicationController

  skip_filter :dashboard_only
  skip_filter :cannot_access_without_joining, :only => [:new, :create]
  skip_filter :check_email_confirmation, :only => [:new, :create]
  
  before_filter :ensure_organization_admin, :except => [:new, :create]
  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_this_page")
  end
  
  
  def new
    @organization = Organization.new
    @organization.email = @current_user.email
    @organization.phone_number = @current_user.phone_number
    @organization.address = @current_user.street_address
  end
  
  def create
    @organization = Organization.new(params[:organization])
    if @organization.merchant_registration == "true" && @organization.valid?
      # Check if any params missing
      if (@organization.email.blank? ||
          @organization.phone_number.blank? || 
          @organization.address.blank? || 
          @organization.website.blank?)
        flash[:error] = t("organizations.form.fill_in_all_details")
        render action: "new" and return
      end
      # save details to the user too, if he doesn't have those filled yet
      @current_user.phone_number ||= params[:phone_number]
      unless @current_user.location
        l = Location.new(:address => params[:address])
        l.search_and_fill_latlng
        l.save
        @current_user.location = l
      end
      
      @organization.register_a_merchant_account
    end

    if @current_user && @organization.save
      membership = OrganizationMembership.create!(:person_id => @current_user.id, :organization_id => @organization.id)
      membership.update_attribute(:admin, true)
      flash[:notice] = t("organizations.new.organization_created")
      redirect_to @organization and return
    else
      flash[:error] = @organization.errors.full_messages
      render action: "new" and return
    end
  end
  
  # currently used only for testing
  def show
    @organization = Organization.find(params[:id])
  end
  
  def edit
    @organization = Organization.find(params[:id])
  end
  
  def update
    @organization = Organization.find(params[:id])
    if @organization.update_attributes(params[:organization])
      if params[:merchant_registration] == "register_as_merchant"
        @organization.register_a_merchant_account
      end
      redirect_to @organization
    else
      render action: "edit" 
    end
  end
  
  private
  
  def ensure_organization_admin
    Organization.find(params[:id]).has_admin?(@current_user)
  end
end
