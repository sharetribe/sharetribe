class PopulateMarketplaceSenderEmails < ActiveRecord::Migration

  class Community < ApplicationRecord
  end

  def up
    regexp_w_quotes = /^"(.+)"\s*<(.+)>$/
    regexp_wo_quotes = /^(.+)\s*<(.+)>$/
    select_query = "SELECT id, custom_email_from_address, created_at, updated_at FROM communities WHERE custom_email_from_address IS NOT NULL"

    sql_values = execute(select_query).map { |(cid, custom_email_from_address, created_at, updated_at)|
      match_w_quotes = regexp_w_quotes.match(custom_email_from_address)
      match_wo_quotes = regexp_wo_quotes.match(custom_email_from_address)

      match = match_w_quotes || match_wo_quotes

      if match
        "(#{cid}, #{connection.quote(match[1])}, #{connection.quote(match[2])}, '#{created_at}', '#{updated_at}')"
      else
        raise ArgumentError.new("Couldn't parse email: #{custom_email_from_address}, community id: #{cid}")
      end
    }

    if sql_values.present?
      execute("INSERT INTO marketplace_sender_emails (community_id, name, email, created_at, updated_at) VALUES #{sql_values.join(', ')}")
    else
      puts "Nothing to do"
    end

  end

  def down
    execute("
      UPDATE communities
      LEFT JOIN marketplace_sender_emails ON (communities.id = marketplace_sender_emails.community_id)
      SET communities.custom_email_from_address = CONCAT('\"', marketplace_sender_emails.name, '\" <', marketplace_sender_emails.email, '>')
      WHERE marketplace_sender_emails.id IS NOT NULL
")
    execute("DELETE FROM marketplace_sender_emails")
  end
end
