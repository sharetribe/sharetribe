class MigrateOrganizationUsers < ActiveRecord::Migration

  def up
    Organization.all.each do |organization|
      name = organization.name
      company_id = organization.company_id
      merchant_id = organization.merchant_id
      merchant_key = organization.merchant_key

      logo_file_or_uri = !organization.logo.blank? && if organization.logo.options[:storage] === :s3 then 
          URI.parse(organization.logo.url)
        else
          File.new(organization.logo.path)
        end

      members = organization.members

      puts "Company '#{name}' with id '#{company_id}', merch.id '#{merchant_id}', merch.key '#{merchant_key}', logo '#{logo_file_or_uri}'"

      # ------------- Skip
      skip_migration = false

      if members.count != 1 then
        puts "ERROR: Company has #{members.count} members! (more than one). Migrate manually."
        puts "Members: #{members.collect(&:name).join(", ")}"
        skip_migration = true
      end

      members_with_multiple_organizations = members.select { |member| member.organizations.count != 1 }

      if members_with_multiple_organizations.length > 0 then
        puts "ERROR: Company has members which represent more than 1 company! Migrate manually."
        members_with_multiple_organizations.each do |member|
          puts "Member '#{member.name}' represents organizations #{member.organizations.collect(&:name).join(", ")}"
        end
        skip_migration = true
      end

      members_with_multiple_communities = members.select { |member| member.communities.count != 1 }

      if members_with_multiple_communities.length > 0 then
        puts "ERROR: Company has members which are members of more than 1 community! Migrate manually."
        members_with_multiple_communities.each do |member|
          puts "Member '#{member.name}' is member of communities #{member.communities.collect(&:name).join(", ")}"
        end
        skip_migration = true
      end
      
      # ------------- Migrate
      unless skip_migration
        puts "Migrating..."
        member = members.first

        # Add organization infor to member
        # These should be safe migrations, since they don't replace any existing data
        member.is_organization = true
        member.organization_name = name
        member.company_id = company_id
        member.checkout_merchant_id = merchant_id
        member.checkout_merchant_key = merchant_key
        
        # Beware! This replaces the existing image!
        if logo_file_or_uri then
          member.image = logo_file_or_uri
        end

        # Save
        member.save!
      end
      puts ""
    end
  end

  def down
    Person.where(:is_organization => true).each do |member|
      member.is_organization = nil
      member.organization_name = nil
      member.company_id = nil
      member.checkout_merchant_id = nil
      member.checkout_merchant_key = nil
      member.image = nil

      # Save
      member.save!      
    end
  end
end
