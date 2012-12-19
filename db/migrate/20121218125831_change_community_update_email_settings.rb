class ChangeCommunityUpdateEmailSettings < ActiveRecord::Migration
  def up
    #If running this script on a server where there is special aalto community present, use different default for that
    a = Community.find_by_domain("aalto")
    Person.all.each do |person|
      person.set_default_preferences if person.preferences.nil?
      if person.preferences["email_about_weekly_events"] == true || person.preferences["email_about_weekly_events"] == "true"
        if a && person.communities.include?(a)
           person.min_days_between_community_updates = 7
        else
           person.min_days_between_community_updates = 1          
        end
      else
        person.min_days_between_community_updates = 100000
      end
      person.preferences.delete("email_about_weekly_events")
      person.save
    end
  end

  def down
    Person.all.each do |person|
      person.set_default_preferences if person.preferences.nil?
      if person.min_days_between_community_updates < 20
        person.preferences["email_about_weekly_events"] = true
      else
        person.preferences["email_about_weekly_events"] = false
      end
      person.save
    end
  end
end
