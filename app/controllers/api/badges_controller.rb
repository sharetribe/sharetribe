class Api::BadgesController < Api::ApiController
  before_filter :find_target_person
  
  def index
    @badges = @person.badges
    respond_with @badges
  end
end