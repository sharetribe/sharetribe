class FollowersController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_this_content")
  end

  def create
    @person = Person.find(params[:person_id] || params[:id])
    PersonHelper.ensure_person_belongs_to_community!(@person, @current_community)

    @person.followers << @current_user
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render :partial => "people/follow_button", :locals => { :person => @person } }
    end
  end

  def destroy
    @person = Person.find(params[:person_id] || params[:id])
    PersonHelper.ensure_person_belongs_to_community!(@person, @current_community)

    @person.followers.delete(@current_user)
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render :partial => "people/follow_button", :locals => { :person => @person } }
    end
  end

end

