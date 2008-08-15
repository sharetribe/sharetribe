class PursesController < ApplicationController
  def index
    save_navi_state(['own','purse'])
  end
end
