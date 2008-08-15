class MessagesController < ApplicationController
  def index
    save_navi_state(['own','inbox','',''])
  end
end
