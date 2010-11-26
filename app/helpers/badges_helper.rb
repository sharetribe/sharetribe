module BadgesHelper
  
  def possible_badges_visible_to?(person)
    person ? [3,4].include?(person.test_group_number) : false
  end
  
end
