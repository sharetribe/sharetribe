class SearchesController < ApplicationController

  def show
    save_navi_state(['', '', '', ''])
    if params[:qa]
      query = params[:qa]
      begin
        s = Ferret::Search::SortField.new(:id_sort, :reverse => true)
        conditions = params[:only_open] ? ["status = 'open' OR status = 'in_progress'"] : ["status = 'open' OR status = 'in_progress' OR status = 'closed'"]
        @listings = Listing.find_by_contents(query, {:limit => 3, :sort => s}, {:conditions => conditions})
      rescue Ferret::QueryParser::QueryParseException
        @invalid = true
      end
    end
  end

end
