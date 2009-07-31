class GroupsController < ApplicationController

  before_filter :logged_in, :except  => [ :index, :search ]
  before_filter :clear_caches, :only => [:create, :join, :leave]

  # Show the group view
  def index
    @title = "groups_title"
    save_navi_state(['groups_title', 'browse_groups'])
    public_group_ids = Group.get_public_group_ids(session[:cookie])
    # add groups to Kassi db if there are new (made in other services)
    Group.add_new_groups_to_kassi_db(public_group_ids)
    
    @groups = Group.paginate( public_group_ids ,{:page => params[:page], :per_page => per_page})
  end
  
  # Show a single group
  def show
    begin
      @group = Group.find(params[:id])
      @members = @group.members(session[:cookie]).paginate :page => params[:page], :per_page => per_page
    rescue RestClient::ResourceNotFound => e
      flash[:error] = :group_not_found
      redirect_to groups_path
    rescue ActiveRecord::RecordNotFound => e
      flash[:error] = :group_not_found
      redirect_to groups_path
    end
  end

  # Show a form for a new group
  def new
    save_navi_state(['groups_title', 'new_group'])
    @group = Group.new
  end

  # Create a new group
  def create
     #should expire groups page cache
    
    @group = Group.new
    begin
      @group = Group.create(params["group"], session[:cookie])
      flash[:notice] = :group_created_successfully
    rescue RestClient::RequestFailed => e
      handle_group_errors(@group, e)
      render :action => :new and return
    rescue RestClient::Unauthorized => e
      handle_group_errors(@group, e)
      render :action => :new and return  
    end
    redirect_to groups_path
  end
  
  # Search groups
  def search
    save_navi_state(['groups_title', 'search_groups'])
  end
  
  # Add person to a group
  def join
    @person = Person.find(params[:person_id])
    @group = Group.find(params[:id])
    @person.join_group(@group.id, session[:cookie])
    flash[:notice] = [ :you_have_joined_to_group, @group.title(session[:cookie]) ]
    redirect_to group_path(params[:id])
  end
  
  # Remove person from a group
  def leave
    @person = Person.find(params[:person_id])
    @group = Group.find(params[:id])
    @person.leave_group(@group.id, session[:cookie])
    group_title = @group.title(session[:cookie])
    if group_title == "Not found!"
      #This happens when the last user leaves a group and the group dies
      group_title = ""
    end
    flash[:notice] = [ :you_have_left_group, @group.title(session[:cookie]), group_path(@group) ]
    redirect_to groups_path
  end
  
  private
  
  def clear_caches
     update_caches_dependent_on_groups(@current_user)
  end
  
  def handle_group_errors(group, exception=nil)
    if exception
      error_array = exception.response.body[2..-3].split('","').each do |error|
        error = error.split(" ", 2)
        group.errors.add(error[0].downcase, error[1]) 
      end
    end
    group.form_title = params[:group][:title]
    group.form_description = params[:group][:description]
  end
  
end
