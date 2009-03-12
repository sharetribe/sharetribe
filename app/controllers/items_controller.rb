class ItemsController < ApplicationController
  
  before_filter :logged_in, :except => [ :index, :show, :hide, :search ]
  
  def index
    save_navi_state(['items','browse_items','',''])
    @letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ#".split("")
    @item_titles = Item.find(:all, :conditions => "status <> 'disabled'", :select => "DISTINCT title", :order => 'title ASC').collect(&:title)
    
    @item_title_hash = {}
    
    #doing hash with all the letters as key values
    @letters.each do |letter|
      @item_title_hash[letter] = Array.new
    end
    
    @item_titles.each do |title|
      if @item_title_hash.has_key?(title[0,1].upcase)
        @item_title_hash[title[0,1].upcase].push(title)
      elsif title[0,2].eql?("ä") || title[0,2].eql?("Ä")
          @item_title_hash["Ä"].push(title)
      elsif title[0,2].eql?("ö") || title[0,2].eql?("Ö")
          @item_title_hash["Ö"].push(title)
      elsif title[0,2].eql?("å") || title[0,2].eql?("Å")
          @item_title_hash["Å"].push(title)
      else
          @item_title_hash["#"].push(title)
      end  
    end
  end
  
  def show
    @title = URI.unescape(params[:id])
    @items = Item.find(:all, :conditions => ["title = ? AND status <> 'disabled'", @title])
    render :update do |page|
      if @items.size > 0
        page["item_" + @title.downcase].replace_html :partial => "item_title_link_and_owners"
      else
        flash[:error] = :no_item_with_such_title
        page["announcement_div"].replace_html :partial => 'layouts/announcements'
      end    
    end  
  end
  
  def hide
    @title = URI.unescape(params[:id])
    render :update do |page|
      page["item_" + @title.downcase].replace_html :partial => "item_title_link", :locals => { :item_title => @title }
    end
  end
  
  def new
    @item = Item.new
    @form_path = items_path
    @cancel_path = cancel_create_person_items_path(@current_user)
    @method = :post
  end
  
  def create
    @item = Item.new(params[:item])
    @person = @item.owner
    render :update do |page|
      if !is_current_user?(@person)
        flash[:error] = :operation_not_permitted
      elsif @current_user.save_item(@item)
        flash[:notice] = :item_added
        flash[:error] = nil
        page["profile_items"].replace_html :partial => "people/profile_item", 
                                           :collection => @current_user.available_items,
                                           :as => :item, 
                                           :spacer_template => "layouts/dashed_line"
        page["profile_add_item"].replace_html :partial => "people/profile_add_item"                                   
      else
        flash[:notice] = nil
        flash[:error] = translate_announcement_error_message(@item.errors.full_messages.first)
      end
      page["announcement_div"].replace_html :partial => 'layouts/announcements'            
    end
  end
  
  def edit
    @item = Item.find(params[:id])
    @form_path = item_path(@item)
    @cancel_path = cancel_update_person_item_path(@item.owner, @item)
    @method = :put
    render :action => :new
  end
  
  def update
    @item = Item.find(params[:id])
    @person = @item.owner
    render :update do |page|
      if !is_current_user?(@item.owner)
        flash[:error] = :operation_not_permitted
        page["item_" + @item.id.to_s].replace_html :partial => 'people/profile_item_inner', :locals => {:item => @item}
      else   
        @item.title = params[:item][:title]
        @item.description = params[:item][:description]
        if @current_user.save_item(@item)
          flash[:notice] = :item_updated
          flash[:error] = nil
          page["item_" + @item.id.to_s].replace_html :partial => 'people/profile_item_inner', :locals => {:item => @item}
        else
          flash[:error] = translate_announcement_error_message(@item.errors.full_messages.first)
        end  
      end
      page["announcement_div"].replace_html :partial => 'layouts/announcements'
    end
  end
  
  def destroy
    logger.info "this is controller"
    @item = Item.find(params[:id])
    @person = @item.owner    
    render :update do |page|
      if !is_current_user?(@person)
        flash[:error] = :operation_not_permitted
      else
        @item.disable
        flash[:notice] = :item_removed
        page["profile_items"].replace_html :partial => "people/profile_item", 
                                           :collection => @current_user.available_items,
                                           :as => :item, 
                                           :spacer_template => "layouts/dashed_line"                             
      end
      page["announcement_div"].replace_html :partial => 'layouts/announcements'          
    end
  end
  
  def search
    save_navi_state(['items', 'search_items'])
    if params[:q]
      query = params[:q]
      begin
        s = Ferret::Search::SortField.new(:title_sort, :reverse => false)
        items = Item.find_by_contents(query, {:sort => s}, {:conditions => "status <> 'disabled'"})
        @items = items.paginate :page => params[:page], :per_page => per_page
      end
    end
  end
  
  def borrow
    @person = Person.find(params[:person_id])
    @item = Item.find(params[:id])
    return unless must_not_be_current_user(@item.owner, :cant_borrow_from_self)
  end
  
  def thank_for
    @item = Item.find(params[:id])
    return unless must_not_be_current_user(@item.owner, :cant_thank_self_for_item)
    @person = Person.find(params[:person_id])
    @kassi_event = KassiEvent.new
    @kassi_event.realizer_id = @person.id
  end
  
  def mark_as_borrowed
    @item = Item.find(params[:kassi_event][:eventable_id])
    return unless must_not_be_current_user(@item.owner, :cant_thank_self_for_item)
    create_kassi_event
    flash[:notice] = :thanks_for_item_sent
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
      page["profile_add_item"].replace_html :partial => "people/profile_add_item"
    end
  end
  
  def cancel_update
    @person = Person.find(params[:person_id])
    @item = Item.find(params[:id])
    render :update do |page|
      page["item_" + @item.id.to_s].replace_html :partial => 'people/profile_item_inner', :locals => {:item => @item}
    end
  end
  
  private
  
  def set_description_visibility(visible)
    partial = visible ? "items/title_and_description" : "items/title_no_description"
    @item = Item.find(params[:id])
    @person = Person.find(params[:person_id])
    render :update do |page|
      page["item_description_#{@item.id}"].replace_html :partial => partial, 
                                                        :locals => { :item => @item }          
    end
  end
  
end
