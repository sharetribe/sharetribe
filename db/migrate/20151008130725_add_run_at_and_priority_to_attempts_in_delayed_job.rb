class AddRunAtAndPriorityToAttemptsInDelayedJob < ActiveRecord::Migration
  def change
    remove_index :delayed_jobs, column: :attempts
    add_index :delayed_jobs, [:attempts, :run_at, :priority]
  end
end
