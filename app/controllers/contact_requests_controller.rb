class ContactRequestsController < ApplicationController
  
  def create
    @contact_request = ContactRequest.new(params[:contact_request])
    session[:contact_request_sent] = true if @contact_request.save
    redirect_to root
  end
  
end