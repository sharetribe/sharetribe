class RequestsController < ApplicationController
  
  def index
    save_navi_state(['own', 'requests'])
    @person = Person.find(params[:person_id])
    @requests = ["kutsu1", "kutsu2"].paginate :page => params[:page], :per_page => per_page
  end

  def accept
    @person = params[:person_id]
    @request = params[:id]
    flash[:notice] = :friend_request_accepted
    redirect_to person_requests_path(@person)
  end

  def reject
    @person = params[:person_id]
    @request = params[:id]
    flash[:notice] = :friend_request_rejected
    redirect_to person_requests_path(@person)
  end

end
