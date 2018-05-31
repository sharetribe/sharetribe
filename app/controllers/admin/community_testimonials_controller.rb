class Admin::CommunityTestimonialsController < Admin::AdminBaseController

  def index
    @selected_left_navi_link = "testimonials"
    @transactions = resource_scope.order("#{sort_column} #{sort_direction}")
      .paginate(:page => params[:page], :per_page => 30)
    @testimonials = testimonials(@transactions)
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
    if params[:direction] == "asc"
      "asc"
    else
      "desc" #default
    end
  end

  def testimonials(transactions)
    pages = transactions.total_pages
    tx_from = transactions.offset + 1
    tx_to = pages > 1 ? (transactions.offset + transactions.length) : transactions.total_entries
    {
      all_count: Testimonial.merge(resource_scope).joins(:tx).count,
      page_count: transactions.map{ |tx| tx.testimonials.size }.sum,
      tx_total_pages: pages,
      tx_from: tx_from,
      tx_to: tx_to,
    }
  end
end
