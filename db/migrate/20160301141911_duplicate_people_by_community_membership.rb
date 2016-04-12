# coding: utf-8
class DuplicatePeopleByCommunityMembership < ActiveRecord::Migration
  def up
    ActiveRecord::Base.transaction do
      select_all(
        [
          "SELECT",
            "p.id,",
            "cm.community_id,",
            "p.created_at,",
            "p.updated_at,",
            "p.is_admin,",
            "p.locale,",
            "p.preferences,",
            "p.active_days_count,",
            "p.last_page_load_date,",
            "p.test_group_number,",
            "p.username,",
            "p.encrypted_password,",
            "p.remember_created_at,",
            "p.sign_in_count,",
            "p.current_sign_in_at,",
            "p.last_sign_in_at,",
            "p.password_salt,",
            "p.given_name,",
            "p.family_name,",
            "p.phone_number,",
            "p.description,",
            "p.facebook_id,",
            "p.authentication_token,",
            "p.community_updates_last_sent_at,",
            "p.min_days_between_community_updates,",
            "p.is_organization,",
            "p.organization_name,",
            "p.deleted",
          "FROM people p",
          "LEFT JOIN community_memberships AS cm ON cm.person_id = p.id ",
          "WHERE cm.person_id IN (",
            "SELECT p.id",
            "FROM people AS p",
            "LEFT OUTER JOIN community_memberships AS cm ON p.id = cm.person_id",
            "GROUP BY p.id",
            "HAVING count(cm.person_id) > 1)"
        ].join(" ")
      ).group_by { |p|
        p['id']
      }.flat_map { |_, people|
        people.drop(1) # drop the first one (that's the original)
      }.each_slice(1000) { |batch|
        execute(insert_clones_query(batch))
      }
    end
  end

  def down
    execute("
      DELETE FROM people
      WHERE cloned_from IS NOT NULL
    ")
  end

  private

  def value_with_null(value)
    if value
      value
    else
      "NULL"
    end
  end

  def quote_with_null(value)
    if value
      quote(value)
    else
      "NULL"
    end
  end

  def date_to_s_with_null(date)
    if date
      quote(date.to_s(:db))
    else
      "NULL"
    end
  end

  def clone_values(people)
    people.map { |p|
      "( #{quote_with_null(SecureRandom.urlsafe_base64)},
         #{p['community_id']},
         #{date_to_s_with_null(p['created_at'])},
         #{date_to_s_with_null(p['updated_at'])},
         #{value_with_null(p['is_admin'])},
         #{quote_with_null(p['locale'])},
         #{quote_with_null(p['preferences'])},
         #{value_with_null(p['active_days_count'])},
         #{date_to_s_with_null(p['last_page_load_date'])},
         #{value_with_null(p['test_group_number'])},
         #{quote_with_null(p['username'])},
         #{quote_with_null(p['encrypted_password'])},
         #{value_with_null(p['remember_created_at'])},
         #{value_with_null(p['sign_in_count'])},
         #{date_to_s_with_null(p['current_sign_in_at'])},
         #{date_to_s_with_null(p['last_sign_in_at'])},
         #{quote_with_null(p['password_salt'])},
         #{quote_with_null(p['given_name'])},
         #{quote_with_null(p['family_name'])},
         #{quote_with_null(p['phone_number'])},
         #{quote_with_null(p['description'])},
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         #{quote_with_null(p['facebook_id'])},
         #{quote_with_null(p['authentication_token'])},
         #{date_to_s_with_null(p['community_updates_last_sent_at'])},
         #{value_with_null(p['min_days_between_community_updates'])},
         #{quote_with_null(p['is_organization'])},
         #{quote_with_null(p['organization_name'])},
         #{value_with_null(p['deleted'])},
         #{quote_with_null(p['id'])})
      "
    }
  end

  def insert_clones_query(people)
    "INSERT INTO people (
        id,
        community_id,
        created_at,
        updated_at,
        is_admin,
        locale,
        preferences,
        active_days_count,
        last_page_load_date,
        test_group_number,
        username,
        encrypted_password,
        remember_created_at,
        sign_in_count,
        current_sign_in_at,
        last_sign_in_at,
        password_salt,
        given_name,
        family_name,
        phone_number,
        description,
        image_file_name,
        image_content_type,
        image_file_size,
        image_updated_at,
        image_processing,
        facebook_id,
        authentication_token,
        community_updates_last_sent_at,
        min_days_between_community_updates,
        is_organization,
        organization_name,
        deleted,
        cloned_from)
      VALUES #{clone_values(people).join(", ")}
    "
  end
end
