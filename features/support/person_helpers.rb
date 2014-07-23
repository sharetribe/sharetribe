module PersonHelpers

  def create_person(username)
    person = FactoryGirl.create(:person, username: username)
    membership = FactoryGirl.create(:community_membership, person: person, community: @current_community)
  end

end

World(PersonHelpers)