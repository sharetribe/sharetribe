class Admin::TestimonialsService
  attr_reader :community, :params

  def initialize(community:, params:)
    @params = params
    @community = community
  end

  def transactions
    @transactions ||= filtered_scope
      .order("#{sort_column} #{sort_direction}")
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
      tx_to: tx_to
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
      testimonial.update(testimonial_params) &&
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

  def unskip
    tx = new_testimonial.tx
    if params_true?(:from_tx_author)
      testimonial.author_id = tx.author.id
      tx.author_skipped_feedback = false
    else
      testimonial.author_id = tx.starter.id
      tx.starter_skipped_feedback = false
    end
    tx.save
  end

  def filter?
    params[:q].present? || params[:status].present?
  end

  def selected_statuses_title
    if params[:status].present?
      I18n.t("admin.communities.testimonials.status_filter.selected", count: params[:status].size)
    else
      I18n.t("admin.communities.testimonials.status_filter.all")
    end
  end

  FILTER_STATUSES = %w(published positive negative skipped waiting blocked)

  def sorted_statuses
    FILTER_STATUSES.map {|status|
      [status, I18n.t("admin.communities.testimonials.status_filter.#{status}"), status_checked?(status)]
    }
  end

  private

  def filtered_scope
    return @filtered_scope if defined?(@filtered_scope)

    scope = transactions_scope

    tx_statuses = []
    tx_statuses.push(Transaction.skipped_feedback) if status_checked?('skipped')
    tx_statuses.push(Transaction.waiting_feedback) if status_checked?('waiting')
    tx_statuses_present = tx_statuses.any?
    scope = merge_statuses(scope, tx_statuses)

    review_statuses = []
    review_statuses.push(Testimonial.non_blocked.positive) if status_checked?('positive')
    review_statuses.push(Testimonial.non_blocked.negative) if status_checked?('negative')
    review_statuses.push(Testimonial.blocked) if status_checked?('blocked')
    review_statuses.push(Testimonial.non_blocked) if status_checked?('published')

    if review_statuses.present?
      review_scope = merge_statuses(Testimonial.by_community(community), review_statuses)
      scope =
        if tx_statuses_present
          scope.or(Transaction.for_testimonials.where(id: review_scope.select('transaction_id')))
        else
          scope.where(id: review_scope.select('transaction_id'))
        end
    end

    @filtered_scope = if params[:q].present?
      scope.search_for_testimonials(community, "%#{params[:q]}%")
    else
      scope
    end
  end

  def transactions_scope
    Transaction.exist.by_community(community.id).for_testimonials
  end

  def testimonials_scope
    Testimonial.joins(:tx).where(transaction_id: filtered_scope.select('transactions.id'))
  end

  def merge_statuses(scope, statuses)
    return scope unless statuses.present?

    status_scope = statuses.shift
    statuses.each{|x| status_scope = status_scope.or(x)}
    scope.merge(status_scope)
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

  def status_checked?(status)
    params[:status].present? && params[:status].include?(status)
  end

end
