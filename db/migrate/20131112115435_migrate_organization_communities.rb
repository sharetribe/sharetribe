class MigrateOrganizationCommunities < ActiveRecord::Migration
  def up
    comms_for_orgs = Community.select do |community|
      community.settings["require_organization_membership"] == true
    end

    comms_for_orgs.each do |community|
      community.settings.delete("require_organization_membership")
      community.only_organizations = true
      community.save!
    end
  end

  def down
    Community.where(:only_organizations => true).all.each do |community|
      community.settings["require_organization_membership"] == true
      community.only_organizations = nil
      community.save!
    end
  end
end
