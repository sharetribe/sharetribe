class GroupsController < ApplicationController

  before_filter :logged_in, :only  => [ :new, :create ]

  def index
    @title = "groups_title"
    save_navi_state(['groups_title', 'browse_groups'])
    @groups = Group.find(:all).paginate :page => params[:page], :per_page => per_page
  end

  def new
    save_navi_state(['groups_title', 'new_group'])
    @group = Group.new
  end

  def create
    begin
      @group = Group.create(params[:group], session[:cookie])
      flash[:notice] = :group_created_successfully
    rescue ActiveResource::BadRequest => e
      flash[:error] = e.response.body
      redirect_to new_group_path and return
    rescue ActiveResource::UnauthorizedAccess => e
      flash[:error] = e.response.body
      redirect_to new_group_path and return  
    end
    redirect_to groups_path
  end
  
  def search
    save_navi_state(['groups_title', 'search_groups'])
  end
  
end
