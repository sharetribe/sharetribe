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
    @testimonial = Testimonial.new
  end

  def create
    @testimonial = Testimonial.new(params[:testimonial])
    if @testimonial.save
      Delayed::Job.enqueue(TestimonialGivenJob.new(@testimonial.id, @current_community))
      flash[:notice] = t("layouts.notifications.feedback_sent_to", :target_person => view_context.link_to(@conversation.other_party(@current_user).given_name_or_username, @conversation.other_party(@current_user))).html_safe
      redirect_to person_message_path(:person_id => @current_user.id, :id => @conversation.id)
    else
      render :action => new
    end
  end

  def skip
    @participation.update_attribute(:feedback_skipped, true)
    respond_to do |format|
      format.html {
        flash[:notice] = t("layouts.notifications.feedback_skipped")
        redirect_to single_conversation_path(:conversation_type => "received", :person_id => @current_user.id, :id => @conversation.id)
      }
      format.js { render :layout => false }
    end
  end

  private

  def ensure_authorized_to_give_feedback
    @conversation = Conversation.find(params[:message_id])
    @participation = Participation.find_by_person_id_and_conversation_id(@current_user, @conversation)
    unless @participation
      flash[:error] = t("layouts.notifications.you_are_not_allowed_to_give_feedback_on_this_transaction")
      redirect_to root and return
    end
  end

  def ensure_feedback_not_given
    unless @participation.feedback_can_be_given?
      flash[:error] = t("layouts.notifications.you_have_already_given_feedback_about_this_event")
      redirect_to root and return
    end
  end

end
