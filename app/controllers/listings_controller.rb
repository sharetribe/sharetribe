class ListingsController < ApplicationController

  before_filter :logged_in, :only  => [ :new, :create, :destroy, :mark_as_interesting, :mark_as_not_interesting, :reply, :close, :commentsap ]
  
  def index
    if params[:person_id]
      @pagination_type = "person_listings" 
      @person = Person.find(params[:person_id])
      @title = :listings_partitive_plural
      conditions = ["author_id = ?" + get_visibility_conditions("listing"), @person.id.to_s ]
      session[:links_panel_navi] = 'listings'
      save_navi_state(['own', 'profile']) if current_user?(@person)
      fetch_listings(conditions, "status DESC, id DESC")
      render :template => "listings/own"
    else
      @pagination_type = "category"
      @title = :all_categories
      save_navi_state(['listings', 'browse_listings', 'all_categories'])
      conditions = "status = 'open' AND good_thru >= '" + Date.today.to_s + "'"
      conditions += get_visibility_conditions("listing")
      fetch_listings(conditions)
    end
  end

  def show
    save_navi_state(['listings', 'browse_listings', 'all_categories']) unless session[:navi2] && !session[:navi2].eql?("")
    @listing = Listing.find(params[:id])
    unless is_visible?(@listing)
      if @current_user
        flash[:error] = :no_permission_to_view_this_content
        redirect_to listings_path
      else  
        session[:return_to] = request.request_uri
        flash[:warning] = :you_must_login_to_do_this
        redirect_to new_session_path and return false
      end  
    end  
    if @current_user && @listing.author.id == @current_user.id
      @listing.comments.each do |comment|
        comment.update_attribute(:is_read, 1)
      end  
    else  
      @listing.update_attribute(:times_viewed, @listing.times_viewed + 1)
    end
  end

  def search
    save_navi_state(['listings', 'search_listings', ''])
    conditions = params[:only_open] ? ["status = 'open' AND good_thru >= ?" + get_visibility_conditions("listing"), Date.today.to_s] : ""
    if params[:q]
      if params[:category] && !params[:category][:category].eql?("")
        if params[:only_open]
          conditions = ["status = 'open' AND good_thru >= ? AND category = ?" + get_visibility_conditions("listing"), Date.today.to_s, params[:category][:category]]
        else  
          conditions = ["category = ?" + get_visibility_conditions("listing"), params[:category][:category]]
        end    
      end
      query = (params[:q].length > 0) ? "*" + params[:q] + "*" : ""
      begin
        s = Ferret::Search::SortField.new(:id_sort, :reverse => true)
        listings = Listing.find_by_contents(query, {:sort => s}, {:conditions => conditions})
        @listings = listings.paginate :page => params[:page], :per_page => per_page
      end    
    end
  end

  def new
    save_navi_state(['listings', 'add_listing', ''])
    @listing = Listing.new
    @listing.good_thru = Date.today + 4.month
  end  

  def create
    get_visibility(:listing)
    @listing = Listing.new(params[:listing])
    language = []
    language << "fi" if (params[:listing][:language_fi].to_s.eql?('1'))
    language << "en" if (params[:listing][:language_en].to_s.eql?('1'))
    language << "swe" if (params[:listing][:language_swe].to_s.eql?('1'))
    @listing.language = language
    if @listing.save
      @listing.save_group_visibilities(params[:groups])
      @listing.newsgroup = params[:newsgroup]
      @listing.post_to_newsgroups(request.protocol + request.host + listing_path(@listing))
      # if RAILS_ENV != "development"
        # @current_user.friends(session[:cookie]).each do |friend|
        #   # Send mail to a friend only if he/she is allowed to see the listing and has
        #   # allowed mail notifications of new listings from friends.
        #   count = Listing.count(:all, :conditions => ["id = ?" + get_visibility_conditions("listing", friend), @listing.id])
        #   if friend.settings.email_when_new_listing_from_friend == 1 && count == 1
        #     UserMailer.deliver_notification_of_new_listing_from_friend(@listing, friend, request.protocol.to_s, request.host.to_s)
        #   end  
        # end  
      # end
      MailWorker.async_send_mail_to_friends_about_listing(:listing_id => @listing.id,
                                                          :cookie => session[:cookie],
                                                          :protocol => request.protocol.to_s,
                                                          :host => request.host.to_s)
      flash[:notice] = :listing_added
      redirect_to listing_path(@listing)
    else
      params[:category] = params[:listing][:category]
      Listing::MAIN_CATEGORIES.each do |main_category|
        if Listing.get_sub_categories(main_category.to_s) && Listing.get_sub_categories(main_category.to_s).include?(params[:listing][:category])
          params[:category] = main_category.to_s
          params[:subcategory] = params[:listing][:category] 
        end
      end
      render :action => "new"
    end
  end 

  def edit
    @listing = Listing.find(params[:id])
    @listing.good_thru = Date.today + 1.month if @listing.good_thru < Date.today
    @object_visibility = @listing.visibility
    return unless must_be_current_user(@listing.author)  
    
    @language_fi = 0
    @language_swe = 0
    @language_en = 0
     
    @listing.language.each do |i|
      if i.eql?("fi")
       @language_fi = 1
      elsif i.eql?("swe")
        @language_swe = 1
      else
        @language_en = 1
      end
    end
    @groups = @listing.groups
  end
  
  def update
    @listing = Listing.find(params[:id])
    language = []
    language << "fi" if (params[:listing][:language_fi].to_s.eql?('1'))
    language << "en" if (params[:listing][:language_en].to_s.eql?('1'))
    language << "swe" if (params[:listing][:language_swe].to_s.eql?('1'))
    @listing.language = language
    get_visibility(:listing)
    if @listing.update_attributes(params[:listing])
      @listing.save_group_visibilities(params[:groups])
      @listing.notify_followers(request, @current_user, true)
      flash[:notice] = :listing_updated
      redirect_to listing_path(@listing)
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @listing = Listing.find(params[:id])
    return unless must_be_current_user(@listing.author)
    @listing.destroy
    flash[:notice] = :listing_removed
    redirect_to listings_path
  end

  def interesting
    @title = :interesting_listings
    save_navi_state(['own', 'interesting_listings'])
    @pagination_type = "interesting_listings"
    save_collection_to_session(@current_user.interesting_listings)
    @listings = @current_user.interesting_listings.paginate :page => params[:page], 
                                 :per_page => per_page.to_i, 
                                 :order => 'id DESC'
    render :template => "listings/index"
  end
  
  def mark_as_interesting
    unless PersonInterestingListing.find_by_person_id_and_listing_id(@current_user.id, params[:id]) 
      @current_user.person_interesting_listings.create(:listing_id => params[:id])
    end
    redirect_to listing_path(Listing.find(params[:id]))   
  end
  
  def mark_as_not_interesting
    PersonInterestingListing.find_by_person_id_and_listing_id(@current_user.id, params[:id]).destroy
    redirect_to listing_path(Listing.find(params[:id]))
  end
  
  def comments
    save_navi_state(['own', 'comments_to_own_listings'])
    @comments = ListingComment.find_by_sql("SELECT listing_comments.id, listing_comments.is_read, listing_comments.created_at, listing_comments.content, listing_comments.listing_id, listings.title, listing_comments.author_id FROM listing_comments, listings WHERE listing_comments.listing_id = listings.id AND listings.author_id = '" + @current_user.id + "' AND listing_comments.author_id <> '" + @current_user.id + "' ORDER BY listing_comments.created_at desc").paginate :page => params[:page], :per_page => per_page.to_i
  end
  
  def close
    @listing = Listing.find(params[:id])
    return unless must_be_current_user(@listing.author)
    #@person = Person.find(params[:person_id])
    @kassi_event = KassiEvent.new
    if params[:rid]
      @kassi_event.realizer_id = params[:rid]
    end
    #@people = get_all_people_array  #ensures that people list is in cache for the auto-complete to work fast
    
    
    # @people = Person.find(:all, :conditions => ["id <> ?", @current_user.id]).collect { 
    #       |p| [ p.name(session[:cookie]) + " (" + p.username(session[:cookie]) + ")", p.id ] 
    #     }
    #     @people.sort! {|a,b| a[0].downcase <=> b[0].downcase}
    #@people = all_people.reject{|p| p[1] == @current_user.id}
    
    @kassi_event.person_comments.build  #required for the form_for the comment inside the form_for event
  end
  
  def mark_as_closed
    @listing = Listing.find(params[:id])
    return unless must_be_current_user(@listing.author)
    
    if params[:realized] == "true"
      if params[:person] && params[:person][:name] && ! params[:person][:name].blank?
        # There is a user name submitted from the form

        realizer_id_array = Array.new
        
        # search from ASI
        hits = Person.search(params[:person][:name])
        if hits["entry"]
          hits["entry"].each do |person|
            # Filter non-kassi users from hits
            if Person.find_by_id(person["id"])
              realizer_id_array.push([nil,person["id"]])
            end
          end
        end
        
        
        if realizer_id_array.length < 1
          flash.now[:error] = :no_match_with_given_name
          @person = @listing.author
          @kassi_event = KassiEvent.new
          render :action => :close and return
        
        elsif realizer_id_array.length > 1
          flash.now[:error] = :given_name_matched_more_than_one
          @person = @listing.author
          @kassi_event = KassiEvent.new
          render :action => :close and return
        end
        
        realizer_id = realizer_id_array[0][1]
        
        if realizer_id == @current_user.id
          flash.now[:error] = :cant_mark_yourself_as_realizer
          @person = @listing.author
          @kassi_event = KassiEvent.new
          render :action => :close and return
        end
        
        params[:kassi_event][:participant_attributes][realizer_id] = @listing.realizer_role
        params[:kassi_event][:comment_attributes].merge!({:author_id => @current_user.id, :target_person_id => realizer_id})
        params[:kassi_event][:pending] = 0
        
        @kassi_event = KassiEvent.new(params[:kassi_event])
        
        if @kassi_event.save
          realizer = Person.find(realizer_id)
          if RAILS_ENV != "development" && realizer.settings.email_when_new_kassi_event == 1
            # puts "REALIZER ON: #{realizer.name}"
            #             puts "EVENTTI: #{@kassi_event.inspect}"
            #             puts "other party: #{@kassi_event.get_other_party(realizer)}"
            UserMailer.deliver_notification_of_new_kassi_event(realizer, @kassi_event, request)
          end
          flash[:notice] = :listing_closed
        else
          puts @kassi_event.person_comments[0].errors.full_messages.inspect         
          @person = @listing.author
          render :action => :close and return
        end
      else
        flash.now[:error] = :realizer_name_missing
        @person = @listing.author
        @kassi_event = KassiEvent.new
        render :action => :close and return
      end
    end
    
    @listing.close!
    redirect_to params[:return_to]
  end
  
  #shows a random listing (that is visible to all)
  def random
    save_navi_state(['listings', 'browse_listings', "all_categories", ''])
    conditions = "status = 'open' AND good_thru >= '" + Date.today.to_s + "'"
    conditions += get_visibility_conditions("listing")
        
    open_listings_ids = Listing.all(:select => "id, title", :conditions => conditions)
    random_id = open_listings_ids[Kernel.rand(open_listings_ids.length)]
    #redirect_to listing_path(random_id)
    @listing = Listing.find_by_id(random_id)
    render :action => :show
  end
  
  # Displays a form for feedback for listing realizer when closing the form
  # def realizer_feedback_form
  #   if params[:realizer] && params[:realizer] != ""
  #     @realizer = Person.find(params[:realizer])
  #     @listing = Listing.find(params[:listing])  
  #   end
  #   render :partial => "realizer_feedback_form"
  # end
  
  # Current user starts to follow this listing
  def follow
    @listing = Listing.find(params[:id])
    @current_user.follow(@listing)
    flash[:notice] = :began_to_follow_listing
    render :update do |page|
      page["follow_link"].replace_html :partial => 'unfollow_link'
      page["announcement_div"].replace_html :partial => 'layouts/announcements'
    end  
  end
  
  # Current user stops following this listing
  def unfollow
    @listing = Listing.find(params[:id])
    @current_user.unfollow(@listing)
    flash[:notice] = :stopped_to_follow_listing
    render :update do |page|
      page["follow_link"].replace_html :partial => 'follow_link'
      page["announcement_div"].replace_html :partial => 'layouts/announcements'
    end
  end
  
  private
  
  def index_cache_path
    if @current_user
      "listings_list/#{session[:locale]}/#{listings_last_changed}/#{@current_user.id}"
    else
       "listings_list/#{session[:locale]}/#{listings_last_changed}/non-registered"
    end
  end
  
  def is_visible?(listing)
    conditions = get_visibility_conditions("listing")
    conditions.slice!(0..3)
    Listing.find(:all, :conditions => conditions).include?(listing)
  end

end
