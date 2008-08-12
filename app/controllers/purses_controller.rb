class PursesController < ApplicationController
  def index
    save_navi_state(['people','purse'])
  end
end
