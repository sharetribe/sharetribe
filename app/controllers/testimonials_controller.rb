class TestimonialsController < ApplicationController
  
  before_filter :except => :index do |controller|
    controller.ensure_logged_in "you_must_log_in_to_give_feedback"
  end
  
  before_filter :ensure_authorized_to_give_feedback, :except => :index
  before_filter :ensure_feedback_not_given, :except => :index
  before_filter :person_belongs_to_current_community, :only => :index
  
  def index
    @testimonials = @person.received_testimonials.paginate(:per_page => 10, :page => params[:page])
    @grade_amounts = @person.grade_amounts
    render :partial => "additional_testimonials" if request.xhr?
  end
  
  def new
    @testimonial = Testimonial.new
  end

  def create
    @testimonial = Testimonial.new(params[:testimonial])
    if @testimonial.save
      Delayed::Job.enqueue(TestimonialGivenJob.new(@testimonial.id, request.host))
      flash[:notice] = ["feedback_sent_to", @conversation.other_party(@current_user).given_name_or_username, @conversation.other_party(@current_user)]
      redirect_to (session[:return_to_inbox_content] || person_message_path(:person_id => @current_user.id, :id => @conversation.id))
    else
      render :action => new
    end    
  end
  
  def skip
    @participation.update_attribute(:feedback_skipped, true)
    flash[:notice] = "feedback_skipped"
    respond_to do |format|
      format.html { redirect_to single_conversation_path(:conversation_type => "received", :person_id => @current_user.id, :id => @conversation.id) }
      format.js { render :layout => false }
    end
  end
  
  private
  
  def ensure_authorized_to_give_feedback
    @conversation = Conversation.find(params[:message_id])
    @participation = Participation.find_by_person_id_and_conversation_id(@current_user, @conversation)
    unless @participation
      flash[:error] = "you_are_not_allowed_to_give_feedback_on_this_transaction"
      redirect_to root and return
    end
  end
  
  def ensure_feedback_not_given
    unless @participation.feedback_can_be_given? 
      flash[:error] = "you_have_already_given_feedback_about_this_event"
      redirect_to root and return
    end  
  end

end
