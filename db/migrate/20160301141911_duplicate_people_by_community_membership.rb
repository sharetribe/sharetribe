class DuplicatePeopleByCommunityMembership < ActiveRecord::Migration
  def up
    ActiveRecord::Base.transaction do
      people = select_all("
                 SELECT p.id AS id, count(cm.person_id) AS cnt
                 FROM people AS p
                 LEFT OUTER JOIN community_memberships AS cm
                 ON p.id = cm.person_id
                 GROUP BY p.id
                 HAVING cnt > 1
               ")

      people.each do |p|
        duplicate_person(p['id'], p['cnt'] - 1)
      end
    end
  end

  def down
    execute("
      DELETE FROM people
      WHERE cloned_from IS NOT NULL
    ")
  end

  private

  def duplicate_person(cloned_from, count)
    count.times {
      insert_person(cloned_from)
    }
  end

  def insert_person(cloned_from)
    execute("
      INSERT INTO people (
        id,
        created_at,
        updated_at,
        is_admin,
        locale,
        preferences,
        active_days_count,
        last_page_load_date,
        test_group_number,
        active,
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
        (SELECT
          #{quote(SecureRandom.urlsafe_base64)},
          created_at,
          updated_at,
          is_admin,
          locale,
          preferences,
          active_days_count,
          last_page_load_date,
          test_group_number,
          active,
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
          #{quote(cloned_from)}
      FROM people
      WHERE id = #{quote(cloned_from)})
    ")
  end
end
