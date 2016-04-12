class UpdateFollowerRelationshipsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    ActiveRecord::Base.transaction do
      relationships = select_all("SELECT * FROM follower_relationships
                                  WHERE follower_id IN
                                    (SELECT DISTINCT cloned_from FROM people
                                    WHERE cloned_from IS NOT NULL)
                                  OR person_id IN
                                    (SELECT DISTINCT cloned_from FROM people
                                    WHERE cloned_from IS NOT NULL); ").to_ary

      insert_values = Array.new
      delete_ids = Array.new

      relationships.each { |r|
        people = expand_person(r['person_id'])
        followers = expand_person(r['follower_id'])

        delete =
          people.inject(true) { |del, person|
            follower = followers.find { |f| f['community_id'] == person['community_id'] }

            if follower
              if person['id'] == r['person_id'] && follower['id'] == r['follower_id']
                false
              else
                insert_values.push(create_insert_values(person['id'], follower['id'], r['created_at'], DateTime.now))
                true
              end
            else
              del
            end
        }

        if delete
          delete_ids.push(r['id'])
        end
      }
      insert_values.each_slice(1000) { |batch|
        execute(create_insert_statement(batch, false))
      }
      delete_ids.each_slice(1000) { |batch|
        execute(create_delete_statement(batch))
      }
    end
  end

  def down
    ActiveRecord::Base.transaction do
      # Remove new additions
      new_relationships =
        select_all("SELECT fr.id AS fr_id, fr.created_at AS fr_created_at,
                       p.id AS person_id, p.cloned_from AS person_cloned_from,
                       f.id AS follower_id, f.cloned_from AS follower_cloned_from
                       FROM follower_relationships AS fr
                       LEFT JOIN people AS p ON fr.person_id = p.id
                       LEFT JOIN people AS f ON fr.follower_id = f.id
                       WHERE
                         p.cloned_from IS NOT NULL OR
                         f.cloned_from IS NOT NULL
                      ").to_ary

      if new_relationships.present?
        insert_values = new_relationships.map { |r|
          p_id = r['person_cloned_from'] || r['person_id']
          f_id = r['follower_cloned_from'] || r['follower_id']
          create_insert_values(p_id, f_id, r['fr_created_at'], DateTime.now)
        }
        delete_ids = new_relationships.map{ |v| quote(v['fr_id']) }

        insert_values.each_slice(1000) { |batch|
          execute(create_insert_statement(batch, true))
        }
        delete_ids.each_slice(1000) { |batch|
          execute(create_delete_statement(batch))
        }
      end
    end
  end

  def expand_person(person_id)
    select_all("SELECT id, community_id FROM people
                WHERE id = #{quote(person_id)} OR
                cloned_from = #{quote(person_id)}").to_ary
  end

  def create_insert_values(person_id, follower_id, created_at, updated_at)
    "(#{quote(person_id)}, #{quote(follower_id)}, #{quote(created_at.to_s(:db))}, #{quote(updated_at.to_s(:db))})"
  end

  def create_insert_statement(insert_values, ignore)
    "INSERT#{ignore ? " IGNORE " : " "}INTO follower_relationships (person_id, follower_id, created_at, updated_at)
     VALUES #{insert_values.join(", ")}"
  end

  def create_delete_statement(ids)
    "DELETE FROM follower_relationships
     WHERE id IN (#{ids.join(", ")})"
  end
end
