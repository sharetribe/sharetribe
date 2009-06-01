class FavorsController < ApplicationController
  
  before_filter :logged_in, :except  => [ :index, :show, :hide, :search ]
  
  def index
    save_navi_state(['favors','browse_favors','',''])
    #TODO cache
    @letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ#".split("")
    @favor_titles = Favor.find(:all, 
                               :conditions => "status <> 'disabled'" + get_visibility_conditions("favor"), 
                               :select => "DISTINCT title", 
                               :order => 'title ASC').collect(&:title)
    @favor_title_hash = {}
    
    #doing hash with all the letters as key values
    @letters.each do |letter|
      @favor_title_hash[letter] = Array.new
    end
    
    @favor_titles.each do |title|
      if @favor_title_hash.has_key?(title[0,1].upcase)
        @favor_title_hash[title[0,1].upcase].push(title)
      elsif title[0,2].eql?("ä") || title[0,2].eql?("Ä")
          @favor_title_hash["Ä"].push(title)
      elsif title[0,2].eql?("ö") || title[0,2].eql?("Ö")
          @favor_title_hash["Ö"].push(title)
      elsif title[0,2].eql?("å") || title[0,2].eql?("Å")
          @favor_title_hash["Å"].push(title)
      else
          @favor_title_hash["#"].push(title)
      end  
    end
     
  end
  
  def show
    @title = URI.unescape(params[:id])
    @favors = Favor.find(:all, :conditions => ["title = ? AND status <> 'disabled'" + get_visibility_conditions("favor"), @title])
    render :update do |page|
      if @favors.size > 0
        page["favor_" + @title.downcase].replace_html :partial => "favor_title_link_and_owners"
      else
        flash[:error] = :no_favor_with_such_title
        page["announcement_div"].replace_html :partial => 'layouts/announcements'
      end    
    end  
  end
  
  def hide
    @title = URI.unescape(params[:id])
    render :update do |page|
      page["favor_" + @title.downcase].replace_html :partial => "favor_title_link", :locals => { :favor_title => @title }
    end
  end
  
  def new
    @favor = Favor.new
    @form_path = favors_path
    @cancel_path = cancel_create_person_favors_path(@current_user)
    @method = :post
  end
  
  def create
    get_visibility(:favor)
    @favor = Favor.new(params[:favor])
    @person = @favor.owner
    @conditions = get_visibility_conditions("favor")
    render :update do |page|
      if !is_current_user?(@person)
        flash[:error] = :operation_not_permitted
      elsif @current_user.save_favor(@favor)
        @favor.save_group_visibilities(params[:groups])
        flash[:notice] = :favor_added
        flash[:error] = nil
        page["profile_favors"].replace_html :partial => "people/profile_favor", 
                                            :collection => @current_user.available_favors(@conditions),
                                            :as => :favor, 
                                            :spacer_template => "layouts/dashed_line"
        page["profile_add_favor"].replace_html :partial => "people/profile_add_favor"                                   
      else
        flash[:notice] = nil
        flash[:error] = translate_announcement_error_message(@favor.errors.full_messages.first)
      end
      page["announcement_div"].replace_html :partial => 'layouts/announcements'            
    end
  end
  
  def edit
    @favor = Favor.find(params[:id])
    @object_visibility = @favor.visibility
    @groups = @favor.groups
    @form_path = favor_path(@favor)
    @cancel_path = cancel_update_person_favor_path(@favor.owner, @favor)
    @method = :put
    render :action => :new
  end
  
  def update
    @favor = Favor.find(params[:id])
    @person = @favor.owner
    get_visibility(:favor)
    render :update do |page|
      if !is_current_user?(@favor.owner)
        flash[:error] = :operation_not_permitted
        page["favor_" + @favor.id.to_s].replace_html :partial => 'people/profile_favor_inner', :locals => {:favor => @favor}
      else   
        @favor.title = params[:favor][:title]
        @favor.description = params[:favor][:description]
        @favor.visibility = params[:favor][:visibility]
        if @current_user.save_favor(@favor)
          @favor.save_group_visibilities(params[:groups])
          flash[:notice] = :favor_updated
          flash[:error] = nil
          page["favor_" + @favor.id.to_s].replace_html :partial => 'people/profile_favor_inner', :locals => {:favor => @favor}
        else
          flash[:error] = translate_announcement_error_message(@favor.errors.full_messages.first)
        end  
      end
      page["announcement_div"].replace_html :partial => 'layouts/announcements'
    end
  end
  
  def destroy
    logger.info "this is controller"
    @favor = Favor.find(params[:id])
    @person = @favor.owner
    @conditions = get_visibility_conditions("favor")    
    render :update do |page|
      if !is_current_user?(@person)
        flash[:error] = :operation_not_permitted
      else
        @favor.disable
        flash[:notice] = [ :removed_favor, h(@favor.title), :undo, undo_destroy_person_favor_path(@current_user, @favor) ]
        page["profile_favors"].replace_html :partial => "people/profile_favor", 
                                           :collection => @current_user.available_favors(@conditions),
                                           :as => :favor, 
                                           :spacer_template => "layouts/dashed_line"                             
      end
      page["announcement_div"].replace_html :partial => 'layouts/announcements'          
    end
  end
  
  def undo_destroy
    @person = Person.find(params[:person_id])
    return unless must_be_current_user(@person)
    @favor = Favor.find(params[:id])
    @favor.enable
    flash[:notice] = [:cancelled_deletion_of_favor, h(@favor.title)]
    redirect_to @person
  end
  
  def search
    save_navi_state(['favors', 'search_favors'])
    if params[:q]
      query = params[:q]
      begin
        s = Ferret::Search::SortField.new(:title_sort, :reverse => false)
        favors = Favor.find_by_contents(query, {:sort => s}, {:conditions => "status <> 'disabled'" + get_visibility_conditions("favor")})
        @favors = favors.paginate :page => params[:page], :per_page => per_page
      end
    end
  end
  
  def ask_for
    @person = Person.find(params[:person_id])
    @favor = Favor.find(params[:id])
    return unless must_not_be_current_user(@favor.owner, :cant_ask_for_own_favor)
  end
  
  def thank_for
    @favor = Favor.find(params[:id])
    return unless must_not_be_current_user(@favor.owner, :cant_thank_self_for_favor)
    @person = Person.find(params[:person_id])
    @kassi_event = KassiEvent.new
    @kassi_event.realizer_id = @person.id  
  end
  
  def mark_as_done
    @favor = Favor.find(params[:kassi_event][:eventable_id])
    return unless must_not_be_current_user(@favor.owner, :cant_thank_self_for_favor)
    create_kassi_event
    flash[:notice] = :thanks_for_favor_sent
    @person = Person.find(params[:person_id])    
    redirect_to @person
  end
  
  def view_description
    set_description_visibility(true)
  end
  
  def hide_description
    set_description_visibility(false)
  end
  
  def cancel_create
    @person = Person.find(params[:person_id])
    render :update do |page|
      page["profile_add_favor"].replace_html :partial => "people/profile_add_favor"
    end
  end
  
  def cancel_update
    @person = Person.find(params[:person_id])
    @favor = Favor.find(params[:id])
    render :update do |page|
      page["favor_" + @favor.id.to_s].replace_html :partial => 'people/profile_favor_inner', :locals => {:favor => @favor}
    end
  end
  
  private
  
  def set_description_visibility(visible)
    partial = visible ? "favors/title_and_description" : "favors/title_no_description"
    @favor = Favor.find(params[:id])
    @person = Person.find(params[:person_id])
    render :update do |page|
      page["favor_description_#{@favor.id}"].replace_html :partial => partial, 
                                                        :locals => { :favor => @favor }          
    end
  end
  
end