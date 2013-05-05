class Api::PeopleController < Api::ApiController

  def index
    if params["email"]
      @people = Person.find_by_email(params["email"])
      @total_pages = 1
    elsif @current_community
      @people = @current_community.members.paginate(:per_page => @per_page, :page => @page)
    else
      response.status = 400
      render :json => ["People search currently only works with email or community_id parameter"] and return
    end
    
    #@total_pages = @listings.total_pages
    @people = [@people] if @people.class == Person # put in array if only single result
    respond_with @people
  end
  
  def show
    @person = Person.find(params["id"])
    
    if current_person == @person
      @show_email = true
    end
    
    respond_with @person
  end
end