class StatisticsController < ApplicationController

  skip_filter  :dashboard_only

  before_filter :ensure_is_admin

  def index

    # Get latest general statistic
    @server_stats = Statistic.where("community_id is NULL").last

    # Get community statistics
    if @current_community
      @community_stats = Statistic.where(:community_id => @current_community.id).last

      # Disable creation of the statistics on the fly as it can take a loong time in big communities
      # if @community_stats.nil? || @community_stats.created_at < 1.day.ago
      #   @community_stats = Statistic.create(:community => @current_community)
      # end
    end

  end
end
