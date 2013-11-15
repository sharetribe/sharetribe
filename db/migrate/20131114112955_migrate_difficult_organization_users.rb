class MigrateDifficultOrganizationUsers < ActiveRecord::Migration

  def migrate_listing_author!(new_author, organization)
    organization.listings.each do |listing|
      old_author = listing.author.name
      listing.update_column(:author_id, new_author.id)

      puts "Listing '#{listing.title}' moved from '#{old_author}' to '#{new_author.name}'"
    end
  end

  def create_new_empty_user
    member = Person.new
    member.password = random_pass
    member.confirmed_at = Time.now
    member.set_default_preferences
    member.locale = "fi"
    member.id = UUID.timestamp_create.to_s22
    member
  end

  def create_new_user_from_old(old_user)
    new_org_user = old_user.dup
    new_org_user.id = UUID.timestamp_create.to_s22
    new_org_user
  end

  def set_membership!(new_org_user)
    # Clean first
    CommunityMembership.where(:person_id => new_org_user.id).destroy_all

    # Membership
    membership = CommunityMembership.new(:person => new_org_user, :community_id => 548, :consent => "SHARETRIBE1.0", :status => "accepted")
    membership.save!
  end

  def org_name_to_username(org_name)
    limit = 19 # 20 - 1 (zero-based)
    org_name.gsub(/[^0-9A-Za-z]/, '_').downcase[0..limit]
  end

  def print_user(user)
    puts "Created new user: #{user.username}"
    puts "Name: #{user.name}"
    puts "Email: #{user.email}"
    puts "Password: #{user.password}"
    puts ""
  end

  def create_new_organization_account!(org, new_member, email)

    # Add organization infor to member
    # These should be safe migrations, since they don't replace any existing data
    new_member.username = org_name_to_username(org.name)
    new_member.is_organization = true
    new_member.organization_name = org.name
    new_member.company_id = org.company_id
    new_member.checkout_merchant_id = org.merchant_id
    new_member.checkout_merchant_key = org.merchant_key
    new_member.email = email
    
    logo_file_or_uri = !org.logo.blank? && if org.logo.options[:storage] === :s3 then 
      URI.parse(org.logo.url)
    else
      File.new(org.logo.path)
    end

    if logo_file_or_uri then
      new_member.image = logo_file_or_uri
    end

    # Save
    new_member.save(validate: false)
    new_member
  end

  def member_email_to_organization_email(org_name, member_email)
    member_email_splitted = member_email.split("@")
    [member_email_splitted.first, "+", org_name_to_username(org_name), "@", member_email_splitted.last].join("")
  end

  def random_pass
    downcase = ('a'..'z').to_a
    upcase = ('A'..'Z').to_a
    numbers = (1..9).to_a

    all = downcase + upcase + numbers

    (0...12).map{ all[rand(all.length)] }.join
  end

  def finalize!(new_org_user, org)
    set_membership!(new_org_user)
    migrate_listing_author!(new_org_user, org)
    print_user(new_org_user)
  end

  def migrate_organization_more_than_one_user!(org, members)
    puts "Using blank user to create new org accoutn for '#{org.name}"

    new_user_base = create_new_empty_user
    email = member_email_to_organization_email(org.name, members.first.email)

    new_org = create_new_organization_account!(org, new_user_base, email)

    finalize!(new_org, org)
  end

  def migrate_user_more_than_one_organization!(member, orgs)
    orgs.each do |org|
      puts "Using member '#{member.name}' to create new org accoutn for '#{org.name}"

      new_user_base = create_new_user_from_old(member)
      email = member_email_to_organization_email(org.name, member.email)
      
      new_org = create_new_organization_account!(org, new_user_base, email)

      finalize!(new_org, org)
    end
  end

  def migrate_organization_member_multiple_communities!(member, orgs, communities)
    orgs.each do |org|
      puts "Using member '#{member.name}' to create new org accoutn for '#{org.name}"

      new_user_base = create_new_user_from_old(member)
      email = member_email_to_organization_email(org.name, member.email)

      new_org = create_new_organization_account!(org, new_user_base, email)

      finalize!(new_org, org)
    end
  end

  def up
    #
    # Case: Organization has multiple users
    #
    puts ""
    puts "#"
    puts "# Case: Organization has multiple users"
    puts "#"
    puts ""
    Organization.select { |org| org.members.count > 1 } .each do |org| 
      puts "'#{org.name}' has more than one user: #{org.members.collect(&:name)}"
      migrate_organization_more_than_one_user!(org, org.members)
    end
    #
    # Case: User has multiple organizations
    #
    # This might take a while...

    puts ""
    puts "#"
    puts "# Case: User has multiple organizations"
    puts "#"
    puts ""
    Person.select { |person| person.organizations.count > 1 } .each do |person| 
      puts "'#{person.name}' represents more than one organizations: #{person.organizations.collect(&:name)}"
      migrate_user_more_than_one_organization!(person, person.organizations)
    end

    #
    # Case: Organization representative is a member of multiple tribes
    #
    # This might take a while...

    puts ""
    puts "#"
    puts "# Case: Organization representative is a member of multiple tribes"
    puts "#"
    puts ""
    Person.select { |person| person.organizations.count > 0 && person.communities.count > 1 } .each do |person|
      puts "'#{person.name}' represents organizations #{person.organizations.collect(&:name)} and is a member in communities: #{person.communities.collect(&:name)}"
      migrate_organization_member_multiple_communities!(person, person.organizations, person.communities)
    end
  end

  def down
  end
end
