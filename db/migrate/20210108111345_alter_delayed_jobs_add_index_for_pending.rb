class AlterDelayedJobsAddIndexForPending < ActiveRecord::Migration[5.2]
  def change
    # Index facilitating polling query for pending jobs. The query looks like:

    # SELECT `delayed_jobs`.* FROM `delayed_jobs` WHERE
    # ((run_at <= '2021-01-08 08:07:08.333490'
    #   AND (locked_at IS NULL OR locked_at < '2021-01-08 08:03:08.333501')
    #  OR locked_by = 'host:foo pid:1')
    #  AND failed_at IS NULL)
    # AND `delayed_jobs`.`queue` IN ('default', 'paperclip', 'mailers')
    # ORDER BY priority ASC, run_at ASC LIMIT 5;

    add_index :delayed_jobs, [:failed_at, :priority, :run_at, :queue, :locked_at, :locked_by], :name => "delayed_jobs_pending_polling"
  end
end
