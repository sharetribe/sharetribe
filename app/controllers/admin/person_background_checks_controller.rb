class Admin::PersonBackgroundChecksController < ApplicationController
  before_filter :ensure_is_admin

  def index
    @community = @current_community
    @bcc = BackgroundCheckContainer.first
    @memberships = CommunityMembership.where(community_id: @current_community.id, status: "accepted")
                                           .includes(person: :emails)
                                           .paginate(page: params[:page], per_page: 5)
    @person_background_check = PersonBackgroundCheck.all
  end

  def bcc_status_select
    @member = Person.find(params[:person_id])
    @bcc = BackgroundCheckContainer.find(params[:bcc_id])
    respond_to do |format|
      format.js {render '/admin/person_background_checks/bcc_status_select' }
    end
  end

  def status_assign
    
  end
end