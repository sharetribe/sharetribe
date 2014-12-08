class CompileCustomStylesheetJob < Struct.new(:community_id, :attempts)

  include DelayedAirbrakeNotification

  MAX_ATTEMPTS = 5

  def initialize(community_id, attempts = 0); super end
  
  def before(job)
    # Nothing?
  end

  def perform
    community = Community.find(community_id)

    if community.stylesheet_needs_recompile? && !community.images_processing?
      CommunityStylesheetCompiler.compile(community)
    elsif community.stylesheet_needs_recompile? && community.images_processing?
      reschedule!
    end
  end
  
  private

  def reschedule!()
    if attempts < MAX_ATTEMPTS
      #reschedule, and increase the time with every attempt
      Delayed::Job.enqueue(CompileCustomStylesheetJob.new(community_id, attempts + 1), run_at: attempts.minutes.from_now)
    else
      raise MaxNumberOfRetriesError.new "Tried compiling custom stylesheet for maximum amount of times for community #{community_id}"
    end
  end
end
