class Api::DevicesController < Api::ApiController
  before_filter :authenticate_person!
  
  def index
    if current_person.id != params[:person_id] 
      response.status = :forbidden
      render :json => ["Can only get the devices of the logged in user"] and return
    end
    
    unless @person = Person.find_by_id(params[:person_id]) 
      response.status = 404
      render :json => ["Could not find person with given person_id"] and return
    end
    
    @devices = @person.devices
    
    respond_with @devices
  end  
  
  def create
    if current_person.id != params[:person_id] 
      response.status = :forbidden
      render :json => ["Can only get the devices of the logged in user"] and return
    end
    
    unless @person = Person.find_by_id(params[:person_id]) 
      response.status = 404
      render :json => ["Could not find person with given person_id"] and return
    end
    
    @device = Device.new(params.slice("device_type", "device_token", "person_id"))
    if @device.save
      response.status = 201 
      respond_with(@device)
    else
      response.status = 400
      render :json => @device.errors.full_messages and return
    end
  end
end
