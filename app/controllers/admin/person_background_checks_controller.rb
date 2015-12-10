class Admin::PersonBackgroundChecksController < ApplicationController
  before_filter :ensure_is_admin

  def index
    @memberships = CommunityMembership.where(community_id: @current_community.id, status: "accepted")
                                           .includes(person: :emails)
                                           .paginate(page: params[:page], per_page: 20)
    @background_check_container = @current_community.background_check_containers
  end

  def people_show
    @person = Person.find(params[:id])
    @background_check_containers = @current_community.background_check_containers
  end

  def update_status
    person = Person.find(params[:id])
    background_check_containers = @current_community.background_check_containers
    background_check_containers.each do |background_check_container|
      # get the value of each background_check_containers from params
      value = params[:background_check_containers]["#{background_check_container.id}"]
      status_ids = []
      # get all status of background_check_container and update status_ids if status are checked.
      bcc_statuses = background_check_container.bcc_statuses
      bcc_statuses.each do |bcc_status|
        if value && value["#{bcc_status.id}"] == '1'
          status_ids << bcc_status.id
        end
      end

      person_background_check = PersonBackgroundCheck.where(background_check_container_id: background_check_container.id, person_id: person.id).first
      if person_background_check.present?
        person_background_check.update_attributes(status_ids: status_ids)
      else
        person.person_background_checks.create(background_check_container_id: background_check_container.id, status_ids: status_ids)
      end
    end
    redirect_to people_admin_community_person_background_checks_path(id: person.id)
  end
end