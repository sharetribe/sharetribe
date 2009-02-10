class RequestsController < ApplicationController
  
  def index
    save_navi_state(['own', 'requests'])
    @person = Person.find(params[:person_id])
    ids = Array.new
    @person.get_friend_requests(session[:cookie])["entry"].each do |person|
      ids << person["id"]
    end
    @requesters = find_kassi_users_by_ids(ids)
  end

  def accept
    begin
      @current_user.add_as_friend(params[:id], session[:cookie])
      flash[:notice] = :friend_request_accepted
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = :accepting_friend_request_failed
    end
    redirect_to :back
  end

  def reject
    begin
      @current_user.remove_pending_friend_request(params[:id], session[:cookie])
      flash[:notice] = :friend_request_rejected
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = :rejecting_friend_request_failed
    end
    redirect_to :back
  end
  
  def cancel
    begin
      @current_user.remove_pending_friend_request(params[:id], session[:cookie])
      flash[:notice] = :friend_request_canceled
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = :canceling_friend_request_failed
    end
    redirect_to :back
  end

end
