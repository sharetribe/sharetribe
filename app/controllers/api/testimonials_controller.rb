class Api::TestimonialsController < Api::ApiController
  before_filter :find_target_person
  
  def index
    @testimonials = @person.received_testimonials.paginate(:per_page => @per_page, :page => @page)
    @grade_amounts = @person.grade_amounts
    @total_pages = @testimonials.total_pages
    respond_with @testimonials
  end
end