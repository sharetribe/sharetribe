class SearchesController < ApplicationController

  def show
    save_navi_state(['', '', '', ''])
    if params[:qa]
      query = (params[:qa].length > 0) ? "*" + params[:qa] + "*" : ""
      person_query = (params[:qa].length > 0) ? params[:qa] : ""
      begin
        sl = Ferret::Search::SortField.new(:id_sort, :reverse => true)
        conditions = ["status = 'open' AND good_thru >= ?" + get_visibility_conditions("listing"), Date.today.to_s]
        @listing_amount = Listing.find_by_contents(query, {:sort => sl}, {:conditions => conditions}).total_hits
        @listings = Listing.find_by_contents(query, {:limit => 2, :sort => sl}, {:conditions => conditions})
        
        si = Ferret::Search::SortField.new(:title_sort, :reverse => true)
        conditions = "status <> 'disabled'" + get_visibility_conditions("item")
        @item_amount = Item.find_by_contents(query, {:sort => si}, {:conditions => conditions}).total_hits
        @items = Item.find_by_contents(query, {:limit => 2, :sort => si}, {:conditions => conditions})
        
        sf = Ferret::Search::SortField.new(:title_sort, :reverse => true)
        conditions = "status <> 'disabled'" + get_visibility_conditions("favor")
        @favor_amount = Favor.find_by_contents(query, {:sort => sf}, {:conditions => conditions}).total_hits
        @favors = Favor.find_by_contents(query, {:limit => 2, :sort => sf}, {:conditions => conditions})
        
        ids = Array.new
        Person.search(person_query)["entry"].each do |person|
          ids << person["id"]
        end
        @people = Person.find_kassi_users_by_ids(ids)
        @person_amount = @people.size
        
        @groups = Group.find(Group.search(person_query, session[:cookie]))
        @group_amount = @groups.size
      end
    end
  end

end
