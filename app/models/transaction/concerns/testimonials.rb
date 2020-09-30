module Testimonials
  extend ActiveSupport::Concern
  include Admin2Helper

  def title_listing
    listing_title || t('admin.communities.transactions.not_available')
  end

  def customer_title
    p = starter
    unless p.deleted
      person_name(p)
    end
  end

  def customer_status(popup = false)
    customer = testimonial_from_starter
    if starter_skipped_feedback
      text = I18n.t('admin2.manage_reviews.statuses.skipped') + ('.' if popup).to_s
      html_class = 'badge-skipped'
    elsif customer.present?
      if customer.blocked?
        text = I18n.t('admin2.manage_reviews.statuses.blocked') + ('.' if popup).to_s
        html_class = 'badge-blocked'
      else
        text, html_class = status_string(customer.positive?, popup)
      end
    else
      text = I18n.t('admin2.manage_reviews.statuses.waiting') + ('.' if popup).to_s
      html_class = 'badge-pending'
    end
    [text, html_class]
  end

  def status_string(positive, popup)
    html_class = ''
    if positive
      rating = I18n.t('admin2.manage_reviews.statuses.positive')
      html_class = 'badge-positive'
    else
      rating =  I18n.t('admin2.manage_reviews.statuses.negative')
      html_class = 'badge-negative'
    end
    if popup
      rating = I18n.t('admin2.manage_reviews.rating', rating: rating)
    end
    [rating, html_class]
  end

  def customer_positive?
    customer = testimonial_from_starter
    return nil unless customer.present?
    return nil if customer.blocked?

    customer.positive?
  end

  def customer_negative?
    customer = testimonial_from_starter
    return nil unless customer.present?
    return nil if customer.blocked?

    !customer.positive?
  end

  def customer_text
    testimonial_from_starter&.text
  end

  def provider_text
    testimonial_from_author&.text
  end

  def provider_title
    p = listing_author
    unless p.deleted
      person_name(p)
    end
  end

  def provider_status(popup = false)
    provider = testimonial_from_author
    if author_skipped_feedback
      text = I18n.t('admin2.manage_reviews.statuses.skipped') + ('.' if popup).to_s
      html_class = 'badge-skipped'
    elsif provider.present?
      if provider.blocked?
        text = I18n.t('admin2.manage_reviews.statuses.blocked') + ('.' if popup).to_s
        html_class = 'badge-blocked'
      else
        text, html_class = status_string(provider.positive?, popup)
      end
    else
      text = I18n.t('admin2.manage_reviews.statuses.waiting') + ('.' if popup).to_s
      html_class = 'badge-pending'
    end
    [text, html_class]
  end

  def provider_positive?
    provider = testimonial_from_author
    return nil unless provider.present?
    return nil if provider.blocked?

    provider.positive?
  end

  def provider_negative?
    provider = testimonial_from_author
    return nil unless provider.present?
    return nil if provider.blocked?

    !provider.positive?
  end
end
