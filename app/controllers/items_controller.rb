class ItemsController < ApplicationController
  def index
    save_navi_state(['items','browse_items','',''])
  end
end
