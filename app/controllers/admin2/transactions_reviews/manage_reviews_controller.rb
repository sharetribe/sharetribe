module Admin2::TransactionsReviews
  class ManageReviewsController < Admin2::AdminBaseController
    before_action :set_service

    def index; end

    def show_review
      tx = @service.transaction
      @review = { reviewReadLabel: t('admin2.manage_reviews.review_label', title: tx.title_listing),
                  customer_title: t('admin2.manage_reviews.customer_title', title: tx.customer_title),
                  customer_status: tx.customer_status(true),
                  customer_text: tx.customer_text,
                  provider_title: t('admin2.manage_reviews.provider_title', title: tx.provider_title),
                  provider_status: tx.provider_status(true),
                  provider_text: tx.provider_text }
      render layout: false
    end

    def edit_review
      @tx = @service.transaction
      render layout: false
    end

    def delete_review
      @tx = @service.transaction
      render layout: false
    end

    def destroy
      @service.destroy_block_customer
      @service.destroy_block_provider
      redirect_to admin2_transactions_reviews_manage_reviews_path
    end

    def update_review
      @service.unskip
      @service.update_customer_rating
      @service.update_provider_rating
      redirect_to admin2_transactions_reviews_manage_reviews_path
    end

    private

    def set_service
      @service = Admin2::TestimonialsService.new(
        community: @current_community,
        params: params)
    end
  end
end
