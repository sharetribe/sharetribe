class UpdateLocationsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    ActiveRecord::Base.transaction do
      cloned_people = select_all("
        SELECT id, cloned_from
        FROM people
        WHERE cloned_from IS NOT NULL AND
        cloned_from IN (
          SELECT DISTINCT person_id
          FROM locations
          WHERE location_type = 'person'
        )
      ").to_ary

      cloned_people.each do |p|
        execute("
          INSERT INTO
          locations
           (latitude, longitude, address, google_address,
            created_at, updated_at, listing_id, person_id,
            location_type, community_id)
          (SELECT
            latitude, longitude, address, google_address,
            created_at, #{quote(DateTime.now.to_s(:db))}, listing_id,
            #{quote(p['id'])}, location_type, community_id
          FROM locations WHERE person_id = #{quote(p['cloned_from'])})
          ")
      end
    end
  end

  def down
    execute("
      DELETE locations
      FROM locations, people
      WHERE
        locations.person_id = people.id AND
        people.cloned_from IS NOT NULL
    ")
  end
end
