class UpdateMessagesBasedOnClonedFrom < ActiveRecord::Migration
  def up
    add_index :messages, :sender_id
    execute("
      UPDATE 
        messages AS m,
        conversations AS c, (
          SELECT id, cloned_from, community_id 
          FROM people
          WHERE cloned_from IS NOT NULL
        ) AS p
      SET m.sender_id = p.id
      WHERE
        m.sender_id = p.cloned_from AND
        c.community_id = p.community_id AND
        m.conversation_id = c.id
      ")
    remove_index :messages, :sender_id
  end

  def down
    add_index :messages, :sender_id
    execute("
      UPDATE messages AS m, people AS p
      SET m.sender_id = p.cloned_from
      WHERE
        m.sender_id = p.id AND
        p.cloned_from IS NOT NULL
      ")
    remove_index :messages, :sender_id
  end
end
