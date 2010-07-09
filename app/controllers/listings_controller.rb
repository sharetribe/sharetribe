class ListingsController < ApplicationController
  
  def home
    @events = ["Event 1", "Event 2", "Event 3"]
    @requests = ["Gorillapuku", "Pyörän korjaus", "Tilapäismajoitus"]
    @offers = ["Kyyti HKI-Turku", "Mikroaaltouuni", "ATK-apu"]
  end
  
  def new
  end  

  def items
  end

  def favors
  end

end
