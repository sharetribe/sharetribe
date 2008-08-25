class PursesController < ApplicationController
  def show
    save_navi_state(['own','purse'])
  end
end
