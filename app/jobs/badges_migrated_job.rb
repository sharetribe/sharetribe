class BadgesMigratedJob < Struct.new(:person_id) 

  def perform
    person = Person.find(person_id)
    puts "Sending mail to #{person.name}"
    PersonMailer.badge_migration_notification(person).deliver
  end

end