class ContactRequestsController < ApplicationController
  
  def create
    @contact_request = ContactRequest.new(params[:contact_request])
    if @contact_request.save
      session[:contact_request_sent] = true 
      PersonMailer.contact_request_notification(@contact_request.email).deliver
    end
    redirect_to root
  end
  
end
