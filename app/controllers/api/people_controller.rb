class Api::PeopleController < Api::ApiController

  # TODO: limit visible attributes based on if the request is authenticated and who is the user

  def show
    @person = Person.find(params["id"])
    
    if current_person == @person
      @show_email = true
    end
    
    respond_with @person
  end
end