# rubocop:disable Rails/Output
class StripeService::CapabilitiesUpdate

  private

  attr_reader :person_id, :community_id, :update_all

  public

  def initialize(person_id: nil, community_id: nil, update_all: nil)
    @person_id = person_id
    @community_id = community_id
    @update_all = update_all
  end

  def update
    if person_id
      if single_person
        update_person(single_person)
      else
        puts "Could not find person person_id='#{person_id}'"
      end
    elsif community_id
      update_community
    elsif update_all
      update_all_stripe_accounts
    else
      puts "No task was given"
    end
  end

  # This will update all member's stripe accounts even if member is banned
  def update_community
    community = Community.find_by(id: community_id)
    if community
      stripe_account_scope.by_community(community).each do |stripe_account|
        update_stripe_account(community, stripe_account)
      end
    else
      puts "Could not find community id='#{community_id}'"
    end
  end

  def update_person(person)
    puts "Processing person person_id='#{person.id}' username='#{person.username}'"
    stripe_account = StripeAccount.find_by(person: person)
    if stripe_account
      update_stripe_account(stripe_account.community, stripe_account)
    else
      puts "Could not find stripe account for person person_id='#{person.id}' username='#{person.username}'"
    end
  end

  def update_all_stripe_accounts
    stripe_account_scope.each do |stripe_account|
      next unless stripe_account.person && stripe_account.community

      puts "Processing person id='#{stripe_account.person.id}'"
      update_stripe_account(stripe_account.community, stripe_account)
    end
  end

  def single_person
    @single_person ||= Person.find_by(id: person_id)
  end

  private

  def update_stripe_account(community, stripe_account)
    result = StripeService::API::StripeApiWrapper.update_account_capabilities(
      community: community,
      account_id: stripe_account.stripe_seller_id
    )
    if result
      stripe_account.update_column(:api_version, StripeService::API::StripeApiWrapper::API_2019_12_03) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def stripe_account_scope
    StripeAccount.active_users
      .where('api_version != ? OR api_version IS NULL', [StripeService::API::StripeApiWrapper::API_2019_12_03])
  end
end
# rubocop:enable Rails/Output
