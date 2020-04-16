class Admin2::TestimonialsService
  attr_reader :community, :params

  def initialize(community:, params:)
    @params = params
    @community = community
  end

  def transactions
    @transactions ||= filtered_scope
      .order("#{sort_column} #{sort_direction}")
      .paginate(page: params[:page], per_page: 100)
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

  def transaction
    @transaction ||= transactions_scope.find(params[:id])
  end

  def count_by_status(status = nil)
    scope = transactions_scope
    tx_statuses = []
    tx_statuses.push(Transaction.skipped_feedback) if status == 'skipped'
    tx_statuses.push(Transaction.waiting_feedback) if status == 'waiting'
    tx_statuses_present = tx_statuses.any?
    scope = merge_statuses(scope, tx_statuses)
    review_statuses = []
    review_statuses.push(Testimonial.non_blocked.positive) if status == 'positive'
    review_statuses.push(Testimonial.non_blocked.negative) if status == 'negative'
    review_statuses.push(Testimonial.blocked) if status == 'blocked'
    review_statuses.push(Testimonial.non_blocked) if status == 'published'
    if review_statuses.present?
      review_scope = merge_statuses(Testimonial.by_community(community), review_statuses)
      scope =
        if tx_statuses_present
          scope.or(Transaction.for_testimonials.where(id: review_scope.select('transaction_id')))
        else
          scope.where(id: review_scope.select('transaction_id'))
        end
    end
    scope.count
  end

  def testimonial
    @testimonial ||= testimonials_scope.find(params[:id])
  end

  def testimonial_blocked_disabled?
    (testimonial.persisted? && !testimonial.blocked) || testimonial.new_record?
  end

  def new_testimonial
    @testimonial = transactions_scope.find(params[:id]).testimonials.build(grade: 1)
  end

  def unskip
    if params[:customer_unskip].present? || params[:provider_unskip].present?
      tx = new_testimonial.tx
      if params[:provider_unskip].present?
        testimonial.author_id = tx.author.id
        tx.author_skipped_feedback = false
      else
        testimonial.author_id = tx.starter.id
        tx.starter_skipped_feedback = false
      end
      tx.save!
    end
  end

  def update_customer_rating
    return unless params[:customer_rating].present?

    testimonial = transaction.testimonial_from_starter || new_testimonial
    testimonial.author = transaction.starter
    testimonial.receiver = transaction.author
    testimonial.grade = params[:customer_rating]
    testimonial.text = params[:customer_comment].presence
    testimonial.save!
  end

  def destroy_block_customer
    if params[:customer_delete_review] && !params[:customer_blocked_review].present?
      transaction.testimonial_from_starter.destroy
    else
      transaction.testimonial_from_starter&.update!(blocked: params[:customer_blocked_review].present?)
    end
  end

  def destroy_block_provider
    if params[:provider_delete_review] && !params[:provider_blocked_review].present?
      transaction.testimonial_from_author.destroy
    else
      transaction.testimonial_from_author&.update!(blocked: params[:provider_blocked_review].present?)
    end
  end

  def update_provider_rating
    return unless params[:provider_rating].present?

    testimonial = transaction.testimonial_from_author || new_testimonial
    testimonial.author = transaction.author
    testimonial.receiver = transaction.starter
    testimonial.grade = params[:provider_rating]
    testimonial.text = params[:provider_comment].presence
    testimonial.save!
  end

  FILTER_STATUSES = %w[positive negative skipped waiting blocked]

  def sorted_statuses
    FILTER_STATUSES.map {|status|
      [status, "#{I18n.t("admin2.manage_reviews.status_filter.#{status}")} (#{count_by_status(status)})", status_checked?(status)]
    }
  end

  def transactions_scope
    Transaction.exist.by_community(community.id).for_testimonials
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
    params[:direction] == 'asc' ? 'asc' : 'desc'
  end

  def params_true?(key)
    !ActiveModel::Type::Boolean::FALSE_VALUES.include?(params[key])
  end

  def status_checked?(status)
    params[:status].present? && params[:status].include?(status)
  end

  def person_name(person)
    display_name = person.display_name.present? ? " (#{person.display_name})" : ''
    "#{person.given_name} #{person.family_name}#{display_name}"
  end
end
