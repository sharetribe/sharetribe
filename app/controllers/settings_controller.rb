class SettingsController < ApplicationController
  def index
    save_navi_state(['people','settings'])
  end
end
