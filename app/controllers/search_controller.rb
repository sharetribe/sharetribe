class SearchController < ApplicationController

  def show
    @query = params[:q]
    if @query
      #query = (params[:q].length > 0) ? "*#{params[:q]}*" : ""
      #person_query = (params[:q].length > 0) ? params[:q] : ""
      
      
      # TODO add requirement for the listing to be open.
      @listings = Listing.search(@query, :page => params[:page], :per_page => 20, :star => true)
      
      puts "TEST #{@listings.count}"
      
      # FIXME: Here performance could be boosted if the contents of the resluting JSON would be used
      # and not only the IDs picked from there, and used to request person details separately.
      # ids = Array.new
      # Person.search(person_query)["entry"].each do |person|
      #   ids << person["id"]
      # end
      # @people = Person.find_kassi_users_by_ids(ids)
      # @person_amount = @people.size
      
      if request.xhr? # checks if AJAX request
        render :partial => "additional_results", :locals => {:listings => @listings}   
      end
      
    end
    
    
  end

end
