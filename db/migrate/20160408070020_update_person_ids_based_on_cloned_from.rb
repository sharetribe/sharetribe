class UpdatePersonIdsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    run_migration_tests!

    ActiveRecord::Base.transaction do
      migrate_person!(table: "community_memberships", column: "person_id")
      migrate_person!(table: "feedbacks",             column: "author_id")
      migrate_person!(table: "invitations",           column: "inviter_id")
      migrate_person!(table: "listings",              column: "author_id")
      migrate_person!(table: "listing_images",        column: "author_id",   community_join_table: "listings",      community_join_table_fk: "listing_id")
      migrate_person!(table: "comments",              column: "author_id")
      migrate_person!(table: "participations",        column: "person_id",   community_join_table: "conversations", community_join_table_fk: "conversation_id")
      migrate_person!(table: "transactions",          column: "starter_id")
      migrate_person!(table: "transactions",          column: "listing_author_id")
      migrate_person!(table: "paypal_accounts",       column: "person_id")
      migrate_person!(table: "messages",              column: "sender_id",   community_join_table: "conversations", community_join_table_fk: "conversation_id")
      migrate_person!(table: "testimonials",          column: "author_id",   community_join_table: "transactions",  community_join_table_fk: "transaction_id")
      migrate_person!(table: "testimonials",          column: "receiver_id", community_join_table: "transactions",  community_join_table_fk: "transaction_id")
      migrate_person!(table: "payments",              column: "payer_id")
      migrate_person!(table: "payments",              column: "recipient_id")
      migrate_person!(table: "braintree_accounts",    column: "person_id")
      migrate_person!(table: "paypal_payments",       column: "merchant_id")
      migrate_person!(table: "paypal_tokens",         column: "merchant_id")
      migrate_person!(table: "listing_followers",     column: "person_id",   community_join_table: "listings",      community_join_table_fk: "listing_id")
    end
  end

  def down
    run_migration_tests!

    ActiveRecord::Base.transaction do
      rollback_person!(table: "community_memberships", column: "person_id")
      rollback_person!(table: "feedbacks",             column: "author_id")
      rollback_person!(table: "invitations",           column: "inviter_id")
      rollback_person!(table: "listings",              column: "author_id")
      rollback_person!(table: "listing_images",        column: "author_id")
      rollback_person!(table: "comments",              column: "author_id")
      rollback_person!(table: "participations",        column: "person_id")
      rollback_person!(table: "transactions",          column: "starter_id")
      rollback_person!(table: "transactions",          column: "listing_author_id")
      rollback_person!(table: "paypal_accounts",       column: "person_id")
      rollback_person!(table: "messages",              column: "sender_id")
      rollback_person!(table: "testimonials",          column: "author_id")
      rollback_person!(table: "testimonials",          column: "receiver_id")
      rollback_person!(table: "payments",              column: "payer_id")
      rollback_person!(table: "payments",              column: "recipient_id")
      rollback_person!(table: "braintree_accounts",    column: "person_id")
      rollback_person!(table: "paypal_payments",       column: "merchant_id")
      rollback_person!(table: "paypal_tokens",         column: "merchant_id")
      rollback_person!(table: "listing_followers",     column: "person_id")
    end
  end

  private

  def migrate_person!(table:, column:, community_join_table: nil, community_join_table_fk: nil)
    name = "Migrate '#{table}.#{column}'"
    exec_update(construct_up_sql(
                  table: table,
                  column: column,
                  community_join_table: community_join_table,
                  community_join_table_fk: community_join_table_fk), name, [])
  end

  def rollback_person!(table:, column:)
    name = "Rollback '#{table}.#{column}'"
    exec_update(construct_down_sql(
                  table: table,
                  column: column), name, [])
  end

  ### Construct SQL

  def construct_up_sql(table:, column:, community_join_table: nil, community_join_table_fk: nil)
    spec =
      if community_join_table.present? && community_join_table_fk.present?
        {
          joined_tables:      "#{table} AS target_table, people AS p, #{community_join_table} AS community_join_table",
          where_community_id: "community_join_table.community_id = p.community_id AND target_table.#{community_join_table_fk} = community_join_table.id"
        }
      else
        {
          joined_tables:      "#{table} AS target_table, people AS p",
          where_community_id: "target_table.community_id = p.community_id"
        }
      end

    [
      "UPDATE #{spec[:joined_tables]}",
      "SET target_table.#{column} = p.id",
      "WHERE target_table.#{column} = p.cloned_from",
      "AND #{spec[:where_community_id]}"
    ].join(" ")
  end

  def construct_down_sql(table:, column:)
    [
      "UPDATE #{table} AS target_table, people AS p",
      "SET target_table.#{column} = p.cloned_from",
      "WHERE target_table.#{column} = p.id",
      "AND p.cloned_from IS NOT NULL"
    ].join(" ")
  end

  ### Tests

  def run_migration_tests!

    # up without join table
    expected_sql = [
      "UPDATE invitations AS target_table, people AS p",
      "SET target_table.inviter_id = p.id",
      "WHERE target_table.inviter_id = p.cloned_from",
      "AND target_table.community_id = p.community_id"].join(" ")

    actual_sql = construct_up_sql(table: "invitations", column: "inviter_id")

    raise "Test failed, expected: #{expected_sql}, actual: #{actual_sql}" unless expected_sql == actual_sql

    # up with join table
    expected_sql = [
      "UPDATE participations AS target_table, people AS p, conversations AS community_join_table",
      "SET target_table.person_id = p.id",
      "WHERE target_table.person_id = p.cloned_from",
      "AND community_join_table.community_id = p.community_id",
      "AND target_table.conversation_id = community_join_table.id"].join(" ")

    actual_sql = construct_up_sql(table: "participations", column: "person_id", community_join_table: "conversations", community_join_table_fk: "conversation_id")

    raise "Test failed, expected: #{expected_sql}, actual: #{actual_sql}" unless expected_sql == actual_sql

    # rollback
    expected_sql = [
      "UPDATE participations AS target_table, people AS p",
      "SET target_table.person_id = p.cloned_from",
      "WHERE target_table.person_id = p.id",
      "AND p.cloned_from IS NOT NULL"].join(" ")

    actual_sql = construct_down_sql(table: "participations", column: "person_id")

    raise "Test failed, expected: #{expected_sql}, actual: #{actual_sql}" unless expected_sql == actual_sql
  end
end
