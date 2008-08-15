class SettingsController < ApplicationController
  def index
    save_navi_state(['own','settings'])
  end
end
