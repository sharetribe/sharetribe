class AvatarsController < ApplicationController
  
  before_filter :logged_in
  
  def edit
    @person = Person.find(params[:person_id])
  end

  def create
    @person = Person.find(params[:person_id])
    begin
      @person.update_avatar(params[:avatar][:image_file], session[:cookie])
      flash[:notice] = :avatar_upload_successful
      redirect_to @person
    rescue ActiveResource::BadRequest => e
      flash[:error] = e.response.body
      render :action => :edit
    end  
  end

end
