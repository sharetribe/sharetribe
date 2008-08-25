class PeopleController < ApplicationController
  
  def index
    save_navi_state(['people', 'browse_people'])
  end
  
  def search
    save_navi_state(['people', 'search_people'])
  end

end
