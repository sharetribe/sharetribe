class AddIndexToDelayedJobAttempts < ActiveRecord::Migration
  def change
    add_index :delayed_jobs, :attempts
  end
end
