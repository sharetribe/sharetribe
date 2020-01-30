# rubocop:disable Rails/Output
class StripeService::CapabilitiesUpdate

  private

  attr_reader :current_community, :person_id, :community_id, :update_all

  public

  def initialize(person_id: nil, community_id: nil, update_all: nil)
    @person_id = person_id
    @community_id = community_id
    @update_all = update_all
  end

  def update
    @current_community = nil
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
    @current_community = Community.find_by(id: community_id)
    if current_community
      current_community.members.each do |person|
        update_person(person)
      end
    else
      puts "Could not find community id='#{community_id}'"
    end
  end

  def update_person(person)
    puts "Processing person person_id='#{person.id}' username='#{person.username}'"
    stripe_account = StripeAccount.find_by(person: person)
    if stripe_account
      @current_community ||= stripe_account.community
      StripeService::API::StripeApiWrapper.update_account_capabilities(
        community: current_community,
        account_id: stripe_account.stripe_seller_id
      )
    else
      puts "Could not find stripe account for person person_id='#{person.id}' username='#{person.username}'"
    end
  end

  def update_all_stripe_accounts
    StripeAccount.all.each do |stripe_account|
      next unless stripe_account.person && stripe_account.community

      puts "Processing person id='#{stripe_account.person.id}'"
      StripeService::API::StripeApiWrapper.update_account_capabilities(
        community: stripe_account.community,
        account_id: stripe_account.stripe_seller_id
      )
    end
  end

  def single_person
    @single_person ||= Person.find_by(id: person_id)
  end
end
# rubocop:enable Rails/Output
