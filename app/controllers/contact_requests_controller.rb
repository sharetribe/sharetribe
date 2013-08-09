class ContactRequestsController < ApplicationController
  
  skip_filter :single_community_only
  
  def create
    @contact_request = ContactRequest.new(params[:contact_request])
    session[:contact_request_sent] = true if @contact_request.save
    PersonMailer.contact_request_notification(@contact_request.email).deliver
    PersonMailer.reply_to_contact_request(@contact_request.email).deliver
    redirect_to root
  end
  
end