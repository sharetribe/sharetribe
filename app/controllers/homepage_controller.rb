class HomepageController < ApplicationController
  
  before_filter :save_current_path
  
  def index
    @events = ["Event 1", "Event 2", "Event 3"]
    @requests = ["Kyyti HKI-Turku", "Mikroaaltouuni", "ATK-apu"]
    @offers = ["Kyyti HKI-Turku", "Mikroaaltouuni", "ATK-apu"]
  end
  
end
