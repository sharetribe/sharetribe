class ProfilesController < ApplicationController
  def index
    save_navi_state(['own','profile'])
  end
end
