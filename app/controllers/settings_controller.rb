class SettingsController < ApplicationController
  def show
    save_navi_state(['own','settings'])
  end
end
