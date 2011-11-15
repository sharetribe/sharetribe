class InvitationCreatedJob < Struct.new(:invitation_id, :host)
  
  def perform
    invitation = Invitation.find(invitation_id)
    PersonMailer.invitation_to_kassi(invitation, host).deliver
  end
  
end