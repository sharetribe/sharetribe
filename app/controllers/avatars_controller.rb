class AvatarsController < ApplicationController
  
  before_filter :logged_in
  
  def edit
    @person = Person.find(params[:person_id])
    @return_url = "#{request.protocol}#{request.host}#{person_path(params[:person_id])}/avatar/upload_successful"
  end

  def create
    if params[:avatar][:cancel]
      redirect_to person_path(params[:person_id])
    end  
    # @person = Person.find(params[:person_id])
    # begin
    #   @person.update_avatar(params[:avatar][:image_file], session[:cookie])
    #   flash[:notice] = :avatar_upload_successful
    #   redirect_to @person
    # rescue RestClient::RequestFailed => e
    #   flash[:error] = e.response.body
    #   render :action => :edit
    # end  
  end
  
  def update
     @person = Person.find(params[:person_id])
    begin
      path = params[:file].path
      original_filename =  params[:file].original_filename
      new_path = path.gsub(/\/[^\/]+\Z/, "/#{original_filename}")
      #puts "UUDEN FILEN polku on: #{new_path}"
      
      #rename the file to get a suffix and content type accepted by COS
      File.rename(path, new_path)
      
      @person.update_avatar(File.new(new_path), session[:cookie])
      flash[:notice] = :avatar_upload_successful
      redirect_to @person
    rescue Exception => e
      puts e.inspect
      flash[:error] = e.message.to_s
      render :action => :edit
    end
  end
  
  def upload_successful
    flash[:notice] = :avatar_upload_successful
    redirect_to person_path(params[:person_id])
  end

end
