class HomepageController < ApplicationController
  
  before_filter :save_current_path
  
  def index
    @events = ["Event 1", "Event 2", "Event 3"]
    @requests = ["Kyyti HKI-Turku", "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore", "ATK-apu"]
    @offers = ["Kyyti HKI-Turku", "Mikroaaltouuni", "ATK-apu"]
  end
  
end
