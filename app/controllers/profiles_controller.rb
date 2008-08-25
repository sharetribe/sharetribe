class ProfilesController < ApplicationController
  def show
    save_navi_state(['own','profile'])
  end
end
