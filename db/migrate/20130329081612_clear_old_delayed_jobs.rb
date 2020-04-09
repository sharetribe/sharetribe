class ClearOldDelayedJobs < ActiveRecord::Migration[5.2]
def up
    # Clear old jobs in the queue (by clearing all)
    Rake::Task['jobs:clear'].invoke
  end

  def down
    # Nothing can be done here.
  end
end
