class FavorsController < ApplicationController
  
  before_filter :logged_in, :except  => [ :index, :show, :search ]
  
  def index
    fetch_favors
  end
  
  def show
    @title = params[:id]
    @favors = Favor.find(:all, :conditions => "title = '" + params[:id].capitalize + "' AND status = 'enabled'")
    fetch_favors
    render :action => :index
  end
  
  def search
    save_navi_state(['favors', 'search_favors'])
    if params[:q]
      query = params[:q]
      begin
        s = Ferret::Search::SortField.new(:title_sort, :reverse => false)
        favors = Favor.find_by_contents(query, {:sort => s}, {:conditions => "status <> 'disabled'"})
        @favors = favors.paginate :page => params[:page], :per_page => per_page
      end
    end
  end
  
  def create
    @favor = Favor.new(params[:favor])
    if @favor.save
      flash[:notice] = :favor_added  
      respond_to do |format|
        format.html { redirect_to @current_user }
        format.js  
      end
    else 
      flash[:error] = :favor_could_not_be_added 
      redirect_to @current_user
    end
  end
  
  def edit
    @editable_favor = Favor.find(params[:id])
    @person = Person.find(params[:person_id])
    show_profile
    render :template => "people/show" 
  end
  
  def update
    @person = Person.find(params[:person_id])
    if params[:favor][:cancel]
      redirect_to person_path(@person) and return
    end  
    @favor = Favor.find(params[:id])
    if @favor.update_attribute(:title, params[:favor][:title])
      flash[:notice] = :favor_updated
    else 
      flash[:error] = :favor_could_not_be_updated
    end    
    redirect_to person_path(@person)
  end
  
  def destroy
    Favor.find(params[:id]).disable
    flash[:notice] = :favor_removed
    redirect_to @current_user
  end
  
  def ask_for
    @person = Person.find(params[:person_id])
    @favor = Favor.find(params[:id])
  end
  
  def thank_for
    @favor = Favor.find(params[:id])
    @person = Person.find(params[:person_id])
    @kassi_event = KassiEvent.new
    @kassi_event.realizer_id = @person.id  
  end
  
  def mark_as_done
    create_kassi_event
    flash[:notice] = :thanks_for_favor_sent
    @person = Person.find(params[:person_id])    
    redirect_to @person
  end
  
  private
  
  def fetch_favors
    save_navi_state(['favors','browse_favors','',''])
    @letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ".split("")
    @favor_titles = Favor.find(:all, :conditions => "status <> 'disabled'", :select => "DISTINCT title", :order => 'title ASC').collect(&:title)
  end
  
end
