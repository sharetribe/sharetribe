class OrganizationsController < ApplicationController

  skip_filter :dashboard_only
  skip_filter :cannot_access_without_joining, :only => [:new, :create]
  
  before_filter :ensure_organization_admin, :except => [:new, :create]
  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_this_page")
  end
  
  
  def new
    @organization = Organization.new
  end
  
  def create
    @organization = Organization.new(params[:organization])
    if params[:merchant_registration] == "register_as_merchant"
      @organization.register_a_merchant_account
    end

    if @current_user && @organization.save
      membership = OrganizationMembership.create!(:person_id => @current_user.id, :organization_id => @organization.id)
      membership.update_attribute(:admin, true)
      flash[:notice] = t("organizations.new.organization_created")
      redirect_to @organization
    else
      flash[:error] = @organization.errors.full_messages
      redirect_to action: "new" 
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
