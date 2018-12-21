class Admin::TestimonialsService
  attr_reader :community, :params

  def initialize(community:, params:)
    @params = params
    @community = community
  end

  def transactions
    @transactions ||= transactions_scope.order("#{sort_column} #{sort_direction}")
      .paginate(page: params[:page], per_page: 30)
  end

  def testimonials
    return @testimonials if defined?(@testimonials)
    pages = transactions.total_pages
    tx_from = transactions.offset + 1
    tx_to = pages > 1 ? (transactions.offset + transactions.length) : transactions.total_entries
    @testimonials = {
      all_count: testimonials_scope.count,
      page_count: transactions.map{ |tx| tx.testimonials.size }.sum,
      tx_total_pages: pages,
      tx_from: tx_from,
      tx_to: tx_to,
    }
  end

  def testimonial
    @testimonial ||= testimonials_scope.find(params[:id])
  end

  def update
    if params[:delete_review] &&
       (params[:testimonial][:blocked].nil? || params[:testimonial][:blocked] == '0')
      testimonial.destroy && testimonial.tx.reload
    else
      testimonial.update_attributes(testimonial_params) &&
        testimonial.tx.reload
    end
  end

  def testimonial_participant
    testimonial.author_id == testimonial.tx.author.id ? :author : :starter
  end

  def testimonial_errors?
    testimonial.errors.any?
  end

  def testimonial_blocked_disabled?
    (testimonial.persisted? && !testimonial.blocked) || testimonial.new_record?
  end

  def new_testimonial
    @testimonial = transactions_scope.find(params[:transaction_id]).testimonials.build(grade: 1)
  end

  def create
    @testimonial = transactions_scope.find(params[:transaction_id]).testimonials.build(testimonial_params)
    @testimonial.author = params_true?(:from_tx_author) ? testimonial.tx.author : testimonial.tx.starter
    @testimonial.receiver = params_true?(:from_tx_author) ? testimonial.tx.starter : testimonial.tx.author
    @testimonial.save
    @testimonial.tx.reload
  end

  private

  def transactions_scope
    Transaction.exist.by_community(community.id).for_testimonials
  end

  def testimonials_scope
    Testimonial.merge(transactions_scope).joins(:tx)
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

  def testimonial_params
    params.require(:testimonial).permit(:text, :grade, :blocked)
  end

  def params_true?(key)
    !ActiveModel::Type::Boolean::FALSE_VALUES.include?(params[key])
  end
end
