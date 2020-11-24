class RemoveFailedInvitationCreatedJobs < ActiveRecord::Migration
  def up
    execute("DELETE FROM `delayed_jobs` WHERE attempts = 3 AND failed_at IS NOT NULL AND `handler` LIKE '%ruby/struct:InvitationCreatedJob%'")
  end

  def down
  end
end
