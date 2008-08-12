class ProfilesController < ApplicationController
  def index
    save_navi_state(['people','profile'])
  end
end
