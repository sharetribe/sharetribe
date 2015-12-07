class Admin::BackgroundCheckContainersController < ApplicationController
  before_filter :ensure_is_admin

  # GET /background_check_containers
  # GET /background_check_containers.json
  def index
    @admin_community_background_check_containers = BackgroundCheckContainer.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admin_community_background_check_containers }
    end
  end

  # GET /background_check_containers/1
  # GET /background_check_containers/1.json
  def show
    @admin_community_background_check_container = BackgroundCheckContainer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin_community_background_check_container }
    end
  end

  # GET /background_check_containers/new
  # GET /background_check_containers/new.json
  def new
    @admin_community_background_check_container = BackgroundCheckContainer.new
    @admin_community_background_check_container.bcc_statuses.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin_community_admin_community_background_check_container }
    end
  end

  # GET /background_check_containers/1/edit
  def edit
    @admin_community_background_check_container = BackgroundCheckContainer.find(params[:id])
  end

  # POST /background_check_containers
  # POST /background_check_containers.json
  def create
    @admin_community_background_check_container = @current_community.background_check_containers.new(background_check_container_params)

    respond_to do |format|
      if @admin_community_background_check_container.save
        format.html { redirect_to admin_community_background_check_containers_path(@current_community), notice: 'Background check container was successfully created.' }
        format.json { render json: @admin_community_background_check_container, status: :created, location: @background_check_container }
      else
        format.html { render action: "new" }
        format.json { render json: @admin_community_background_check_container.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /background_check_containers/1
  # PATCH/PUT /background_check_containers/1.json
  def update
    @admin_community_background_check_container = BackgroundCheckContainer.find(params[:background_check_container_id])

    respond_to do |format|
      if @admin_community_background_check_container.update_attributes(background_check_container_params)
        format.html { redirect_to admin_community_background_check_containers_path(@current_community), notice: 'Background check container was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin_community_background_check_container.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /background_check_containers/1
  # DELETE /background_check_containers/1.json
  def destroy
    @admin_community_background_check_container = BackgroundCheckContainer.find(params[:id])
    @admin_community_background_check_container.destroy

    respond_to do |format|
      format.html { redirect_to admin_community_background_check_containers_path(@current_community) }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def background_check_container_params
      params.require(:background_check_container).permit(:active, :button_text, :community_id, :container_type, :icon, :name, :placeholder_text, :visible, bcc_statuses_attributes: [:id, :status, :bg_color, :_destroy])
    end
end
