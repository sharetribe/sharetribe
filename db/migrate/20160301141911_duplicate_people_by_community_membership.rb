class DuplicatePeopleByCommunityMembership < ActiveRecord::Migration
  def up
    people = select_values("
               SELECT p.id
               FROM people AS p
               LEFT OUTER JOIN community_memberships AS cm
               ON p.id = cm.person_id
               GROUP BY p.id
               HAVING count(cm.person_id) > 1
             ")
    people.each do |person_id|
      memberships = select_all("
        SELECT * FROM community_memberships WHERE person_id = #{quote(person_id)}
      ").to_ary
      unless memberships.empty?
        head, *tail = memberships
        insert_people(person_id, tail)
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

  def insert_people(cloned_from, memberships)
    memberships.each do |m|
      insert_person(cloned_from)
    end
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
