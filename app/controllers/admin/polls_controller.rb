class Admin::PollsController < ApplicationController

  layout "layouts/admin"

  before_filter :ensure_is_admin, :ensure_polls_enabled

  def index
    @polls = @current_community.polls.order("created_at DESC")
  end

  def show
    @poll = Poll.find(params[:id])
  end

  def new
    @poll = Poll.new
    @poll.options = [PollOption.new, PollOption.new]
    @path = admin_polls_path
    session[:option_amount] = 2
  end

  def edit
    @poll = Poll.find(params[:id])
    @path = admin_poll_path(@poll)
    session[:option_amount] = @poll.options.size
    render :action => :new
  end

  def create
    @poll = Poll.new(params[:poll])
    @current_community.active_poll.update_attribute(:active, false) if @current_community.active_poll
    if @poll.save
      flash[:notice] = "poll_created"
      redirect_to admin_polls_path(:type => "polls")
    else
      flash[:error] = "poll_creation_failed"
      render :action => :new
    end
  end

  def update
    @poll = Poll.find(params[:id])
    if @poll.update_attributes(params[:poll])
      flash[:notice] = "poll_updated"
      redirect_to admin_polls_path(:type => "poll")
    else
      flash[:error] = "poll_update_failed"
      @path = admin_poll_path(:id => @poll.id.to_s)
      render :action => :new
    end
  end

  def destroy
    Poll.find(params[:id]).destroy
    flash[:notice] = "poll_deleted"
    redirect_to admin_polls_path(:type => "poll")
  end

  def add_option
    session[:option_amount] += 1
    respond_to do |format|
      format.html { redirect_to new_admin_poll_path }
      format.js { render :layout => false }
    end
  end

  def remove_option
    respond_to do |format|
      format.html { redirect_to new_admin_poll_path }
      format.js { render :layout => false }
    end
  end

  def open
    change_status(true)
  end

  def close
    change_status(false)
  end

  private

  def change_status(status)
    if status && @current_community.active_poll
      @previously_active_poll = @current_community.active_poll
      @previously_active_poll.update_attribute(:active, false)
    end
    @poll = Poll.find(params[:id])
    @poll.update_attribute(:active, status)
    notice = "poll_#{@poll.status}ed"
    respond_to do |format|
      format.html {
        flash[:notice] = notice
        redirect_to admin_polls_path
      }
      format.js {
        flash.now[:notice] = notice
        render :open, :layout => false
      }
    end
  end

  def ensure_polls_enabled
    redirect_to admin_news_items_path unless @current_community.polls_enabled?
  end

end
