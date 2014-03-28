class ContactRequestsController < ApplicationController

  skip_filter :single_community_only

  def create
    @contact_request = ContactRequest.new(params[:contact_request])
    session[:contact_request_sent] = @contact_request.id if @contact_request.save
    redirect_to root
  end

  def update
    @contact_request = ContactRequest.find(params[:id])
    session[:contact_request_completed] = true if @contact_request.update_attributes(params[:contact_request])
    PersonMailer.contact_request_notification(@contact_request).deliver
    PersonMailer.reply_to_contact_request(@contact_request).deliver
    redirect_to root
  end

end
