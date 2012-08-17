class HobbiesController < ApplicationController
  
  layout :choose_layout

  before_filter :only => [:show] do |controller|
    controller.ensure_logged_in nil
  end

  skip_filter :not_public_in_private_community, :dashboard_only
  skip_filter :single_community_only, :only => :create

  def show
    # get list of 'official' hobbies
    @official_hobbies = Hobby.where(:official => true)

    # collect the current user's non-'official' hobbies
    @other_hobbies = @current_person.hobbies.select { |x| x.official == false }
  end
  
  private
  
  def choose_layout
    if @current_community.private
      'private'
    else
      'application'
    end
  end
  

end
