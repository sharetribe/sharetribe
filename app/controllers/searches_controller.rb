class SearchesController < ApplicationController

  def show
    save_navi_state(['', '', '', ''])
    if params[:qa]
      query = params[:qa]
      begin
        sl = Ferret::Search::SortField.new(:id_sort, :reverse => true)
        conditions = ["status = 'open'"]
        @listing_amount = Listing.find_by_contents(query, {:sort => sl}, {:conditions => conditions}).total_hits
        @listings = Listing.find_by_contents(query, {:limit => 3, :sort => sl}, {:conditions => conditions})
        
        si = Ferret::Search::SortField.new(:title_sort, :reverse => false)
        @items = Item.find_by_contents(query, {:limit => 3, :sort => si}, {:conditions => ''})
        
        sf = Ferret::Search::SortField.new(:title_sort, :reverse => false)
        @favors = Favor.find_by_contents(query, {:limit => 3, :sort => sf}, {:conditions => ''})
      end
    end
  end

end
