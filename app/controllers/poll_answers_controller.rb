class PollAnswersController < ApplicationController

  skip_filter :dashboard_only

  def create
    @poll_answer = PollAnswer.new(params[:poll_answer])
    if @poll_answer.save
      notice = [:notice, "poll_answered"]
      @poll_answer.poll.calculate_percentages
    else
      notice = [:error, "poll_could_not_be_answered"]
    end
    respond_to do |format|
      format.html {
        flash[notice[0]] = notice[1]
        redirect_to root
      }
      format.js {
        flash.now[notice[0]] = notice[1]
        render :layout => false
      }
    end
  end

end
