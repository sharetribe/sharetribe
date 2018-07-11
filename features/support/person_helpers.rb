module PersonHelpers

  def create_person(username)
    person = FactoryBot.create(:person,
      username: username,
      community_id: @current_community.id,
      emails: [
        FactoryBot.build(:email, address: "#{username}@example.com", person: person)
      ]
    )
    membership = FactoryBot.create(:community_membership, person: person, community: @current_community)
  end

end

World(PersonHelpers)
