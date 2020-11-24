class Admin::InvitationsService
  attr_reader :community, :params

  def initialize(community:, params:)
    @params = params
    @community = community
  end

  def invitations
    @invitations ||= resource_scope.order(Arel.sql("#{sort_column} #{sort_direction}"))
      .paginate(page: params[:page], per_page: 30)
  end

  private

  def resource_scope
    community.invitations.exist.joins(:inviter).includes(:inviter)
  end

  def sort_column
    case params[:sort]
    when 'sent_by'
      'CONCAT(people.given_name, people.family_name)'
    when 'sent_to'
      'invitations.email'
    when 'used'
      'invitations.usages_left'
    when 'started', nil
      'invitations.created_at'
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
