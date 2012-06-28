class Api::PeopleController < Api::ApiController

  def show
    @person = Person.find(params["id"])
    respond_with @person
  end
end