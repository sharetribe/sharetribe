class DuplicateLocationsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    execute("
      INSERT INTO locations
        (latitude, longitude, address, google_address, created_at, updated_at, person_id, location_type)
        (SELECT l.latitude, l.longitude, l.address, l.google_address, l.created_at, l.updated_at, cloned_people.id, 'person'
         FROM locations as l
         LEFT JOIN people AS cloned_people ON cloned_people.cloned_from = l.person_id          WHERE l.location_type = 'person'
           AND cloned_people.cloned_from IS NOT NULL)
      ")
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
