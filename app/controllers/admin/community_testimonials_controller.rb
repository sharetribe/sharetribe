class Admin::CommunityTestimonialsController < Admin::AdminBaseController

  def index
    @selected_left_navi_link = "testimonials"
    @transactions = resource_scope.order("#{sort_column} #{sort_direction}")
      .paginate(:page => params[:page], :per_page => 30)
  end

  private

  def resource_scope
    Transaction.exist.by_community(@current_community.id).for_testimonials
  end

  def sort_column
    case params[:sort]
    when 'started', nil
      'transactions.created_at'
    end
  end

  def sort_direction
    params[:direction] || 'desc'
  end
end
