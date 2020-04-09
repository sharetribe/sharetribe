class RemoveFailedInvitationCreatedJobs < ActiveRecord::Migration[5.2]
  def up
    execute("DELETE FROM `delayed_jobs` WHERE attempts = 3 AND failed_at IS NOT NULL AND `handler` LIKE '%ruby/struct:InvitationCreatedJob%'")
  end

  def down
  end
end
