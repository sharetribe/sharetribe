class Admin::CommunityTestimonialsController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service

  layout false, only: [:edit, :update, :new, :create]
  respond_to :html, :js

  def index; end

  def edit; end

  def update
    @service.update
  end

  def new
    @service.new_testimonial
  end

  def create
    @service.create
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = "testimonials"
  end

  def set_service
    @service = Admin::TestimonialsService.new(
      community: @current_community,
      params: params)
  end
end
