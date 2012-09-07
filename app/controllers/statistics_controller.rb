class StatisticsController < ApplicationController

  skip_filter :single_community_only, :dashboard_only
  
  layout 'dashboard'
  
  
  def index
    
    # Get latest general statistic
    @server_stats = Statistic.where("community_id is NULL").last
        
    # Get community statistics
    if @current_community 
      @community_stats = Statistic.where(:community_id => @current_community.id).last
      if @community_stats.nil? || @community_stats.created_at < 1.day.ago
        @community_stats = Statistic.create(:community => @current_community)
      end
    end
    
  end
end