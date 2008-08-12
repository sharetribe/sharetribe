class MessagesController < ApplicationController
  def index
    save_navi_state(['people','inbox','',''])
  end
end
