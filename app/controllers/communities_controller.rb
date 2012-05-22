class CommunitiesController < ApplicationController
  
  layout 'dashboard'
  
  respond_to :html, :json
  
  def index
    @communities = Community.joins(:location).select("communities.id, name, settings, domain, members_count, latitude, longitude")
    respond_with(@communities) do |format|
      format.json { render :json => { :data => @communities } }
      format.html #show the communities map
    end
  end

  # GET /communities/1
  # GET /communities/1.xml
  def show
    @community = Community.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @community }
    end
  end

  # GET /communities/new
  # GET /communities/new.xml
  def new
    @community = Community.new
    @community.community_memberships.build
    unless @community.location
      @community.build_location(:address => @community.address, :type => 'community')
      @community.location.search_and_fill_latlng
    end
    @person = Person.new
    session[:community_category] = params[:category] if params[:category]
    session[:pricing_plan] = params[:pricing_plan] if params[:pricing_plan]
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @community }
    end
  end

  # GET /communities/1/edit
  def edit
    @community = Community.find(params[:id])
  end

  # POST /communities
  # POST /communities.xml
  def create
    params[:community][:location][:address] = params[:community][:address] if params[:community][:address]
    location = Location.new(params[:community][:location])
    params[:community].delete(:location)
    params[:community].delete(:address)
    logger.info params.inspect
    @community = Community.new(params[:community])
    @community.save
    location.community = @community
    location.save
    session[:community_category] = session[:pricing_plan] = nil
    render :action => :new
  end

  # PUT /communities/1
  # PUT /communities/1.xml
  def update
    @community = Community.find(params[:id])

    respond_to do |format|
      if @community.update_attributes(params[:community])
        format.html { redirect_to(@community, :notice => 'Community was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @community.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /communities/1
  # DELETE /communities/1.xml
  def destroy
    @community = Community.find(params[:id])
    @community.destroy

    respond_to do |format|
      format.html { redirect_to(communities_url) }
      format.xml  { head :ok }
    end
  end
  
  def check_domain_availability
    respond_to do |format|
      format.json { render :json => Community.domain_available?(params[:community][:domain]) }
    end
  end
  
end
