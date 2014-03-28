module BadgesHelper

  # This methods can be used to control whether possible badges
  # are shown to this person. Currently everybody sees all possiblebadges.
  def possible_badges_visible_to?(person)
    true
    # person ? [3,4].include?(person.test_group_number) : false
  end

end
