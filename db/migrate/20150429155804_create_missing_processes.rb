class CreateMissingProcesses < ActiveRecord::Migration
  def up
    # add 'none', author_is_seller: true
    execute("
      INSERT INTO transaction_processes (
        community_id, author_is_seller, process, created_at, updated_at)
      (
        SELECT c.id, true, 'none', NOW(), NOW()
        FROM communities c

        # Avoid duplicates
        LEFT JOIN transaction_processes tp ON (
          tp.community_id = c.id AND
          tp.author_is_seller = true AND
          tp.process = 'none')

        WHERE tp.id IS NULL
      )
    ")

    # add 'none', author_is_seller: false
    execute("
      INSERT INTO transaction_processes (
        community_id, author_is_seller, process, created_at, updated_at)
      (
        SELECT c.id, false, 'none', NOW(), NOW()
        FROM communities c

        # Avoid duplicates
        LEFT JOIN transaction_processes tp ON (
          tp.community_id = c.id AND
          tp.author_is_seller = false AND
          tp.process = 'none')

        WHERE tp.id IS NULL
      )
    ")
  end

  def down
    # Nothing
  end
end
