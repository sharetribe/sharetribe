class CompileCustomStylesheetJob < Struct.new(:community_id)
  
  include DelayedAirbrakeNotification

  def before(job)
    # Nothing?
  end
  
  def perform
    community = Community.find(community_id)
    unless community.has_custom_stylesheet?
      CommunityStylesheetCompiler.compile(community)
    end
  end
end