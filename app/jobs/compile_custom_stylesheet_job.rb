class CompileCustomStylesheetJob < Struct.new(:community_id)

  include DelayedAirbrakeNotification

  def before(job)
    # Nothing?
  end

  def perform
    community = Community.find(community_id)
    if community.stylesheet_needs_recompile?
      CommunityStylesheetCompiler.compile(community)
    end
  end
end
