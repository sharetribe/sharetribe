class GroupsController < ApplicationController

  before_filter :logged_in, :except  => [ :index, :search ]

  def index
    @title = "groups_title"
    save_navi_state(['groups_title', 'browse_groups'])
    Group.add_new_public_groups_to_kassi_db(session[:cookie])
    @groups = Group.paginate(:page => params[:page], :per_page => per_page)
  end
  
  def show
    @group = Group.find(params[:id])
    @members = @group.members(session[:cookie]).paginate :page => params[:page], :per_page => per_page
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
  
  def join
    @person = Person.find(params[:person_id])
    @person.join_group(params[:id], session[:cookie])
    flash[:notice] = :you_have_joined_to_this_group
    redirect_to group_path(params[:id])
  end
  
end
