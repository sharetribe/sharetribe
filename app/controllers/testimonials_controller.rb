class TestimonialsController < ApplicationController

  before_filter :except => :index do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_give_feedback")
  end

  before_filter :ensure_authorized_to_give_feedback, :except => :index
  before_filter :ensure_feedback_not_given, :except => :index
  before_filter :person_belongs_to_current_community, :only => :index

  skip_filter :dashboard_only
  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_filter :verify_authenticity_token, :only => [:skip]

  def index
    if request.xhr?
      @testimonials = @person.received_testimonials.paginate(:per_page => params[:per_page], :page => params[:page])
      limit = params[:per_page].to_i
      render :partial => "people/testimonials", :locals => {:received_testimonials => @testimonials, :limit => limit}
    else
      redirect_to person_path(@person)
    end
  end

  def new
    transaction = Transaction.find(params[:message_id])
    testimonial = Testimonial.new
    render(locals: { transaction: transaction, testimonial: testimonial})
  end

  def create
    @testimonial = @transaction.testimonials.build(params[:testimonial])

    if @testimonial.save
      Delayed::Job.enqueue(TestimonialGivenJob.new(@testimonial.id, @current_community))
      flash[:notice] = t("layouts.notifications.feedback_sent_to", :target_person => view_context.link_to(@transaction.other_party(@current_user).given_name_or_username, @transaction.other_party(@current_user))).html_safe
      redirect_to person_transaction_path(:person_id => @current_user.id, :id => @transaction.id)
    else
      render :action => new
    end
  end

  def skip
    is_author = @transaction.author == @current_user

    if is_author
      @transaction.update_attributes(author_skipped_feedback: true)
    else
      @transaction.update_attributes(starter_skipped_feedback: true)
    end

    respond_to do |format|
      format.html {
        flash[:notice] = t("layouts.notifications.feedback_skipped")
        redirect_to single_conversation_path(:conversation_type => "received", :person_id => @current_user.id, :id => @transaction.id)
      }
      format.js { render :layout => false, locals: {is_author: is_author} }
    end
  end

  private

  def ensure_authorized_to_give_feedback
    # Rails was giving some read-only records. That's why we have to do some manual queries here and use INCLUDES,
    # not joins.
    # TODO Move this to service
    @transaction = Transaction
      .includes(:listing)
      .where("starter_id = ? OR listings.author_id = ?", @current_user.id, @current_user.id)
      .where({
        community_id: @current_community.id,
        id: params[:message_id]
      }).first

    if @transaction.nil?
      flash[:error] = t("layouts.notifications.you_are_not_allowed_to_give_feedback_on_this_transaction")
      redirect_to root and return
    end
  end

  def ensure_feedback_not_given
    transaction_entity = MarketplaceService::Transaction::Entity.transaction(@transaction)
    waiting = MarketplaceService::Transaction::Entity.waiting_testimonial_from?(transaction_entity, @current_user.id)

    unless waiting
      flash[:error] = t("layouts.notifications.you_have_already_given_feedback_about_this_event")
      redirect_to root and return
    end
  end

end
