class DuplicateEmailBasedOnClonedFrom < ActiveRecord::Migration
  def up
    execute("
      INSERT INTO emails
        (person_id, community_id, address, confirmed_at, confirmation_sent_at, confirmation_token, created_at, updated_at, send_notifications)
        (SELECT cloned_people.id, cloned_people.community_id, e.address, e.confirmed_at,
          e.confirmation_sent_at, e.confirmation_token, e.created_at, e.updated_at, e.send_notifications
          FROM emails AS e
          LEFT JOIN people AS cloned_people ON cloned_people.cloned_from = e.person_id
          WHERE cloned_people.cloned_from IS NOT NULL)
    ")
  end

  def down
    execute("
      DELETE emails
      FROM emails, people
      WHERE
        emails.person_id = people.id AND
        people.cloned_from IS NOT NULL
      ")
  end
end
