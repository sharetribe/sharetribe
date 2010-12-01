class BadgesMigratedJob < Struct.new(:person_id) 

  def perform
    person = Person.find(person_id)
    PersonMailer.badge_migration_notification(person).deliver
  end

end