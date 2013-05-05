class ClearOldDelayedJobs < ActiveRecord::Migration
  def up
    # Clear old jobs in the queue (by clearing all)
    Rake::Task['jobs:clear'].invoke
  end

  def down
    # Nothing can be done here.
  end
end
