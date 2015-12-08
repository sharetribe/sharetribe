class Admin::PersonBackgroundChecksController < ApplicationController
  before_filter :ensure_is_admin

  def index
    @community = @current_community
    @memberships = CommunityMembership.where(community_id: @current_community.id, status: "accepted")
                                           .includes(person: :emails)
                                           .paginate(page: params[:page], per_page: 5)
  end

  def bcc_status_select
    @member = Person.find(params[:person_id])
    @bcc = BackgroundCheckContainer.find(params[:bcc_id])
    respond_to do |format|
      format.js {render '/admin/person_background_checks/bcc_status_select' }
    end
  end

  def assign_status
    person = Person.find(params[:person_id])
    bcc = BackgroundCheckContainer.find(params[:bcc_id])
    bcc_status = BccStatus.find(params[:bcc_status_id])
    status_ids = []
    status_ids << bcc_status.id
    person_background_check = PersonBackgroundCheck.where(background_check_container_id: bcc.id, person_id: person.id).first

    if person_background_check.present?
      person_background_check.status_ids.to_a do |status_id|
        status_ids << status_id
      end
      person_background_check.update_attributes(status_ids: status_ids)
      person_background_check.save
    else
      person.person_background_checks.create(background_check_container_id: bcc.id)
    end
    # redirect_to admin_community_person_background_checks_path
  end
end