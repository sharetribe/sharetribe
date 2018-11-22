module TestimonialViewUtils

  module_function

  # Filters out those testimonials that do not belong to this community
  # These methods are temporary and only needed until the possibility to have
  # one account in many communities is disabled. Then these can be deleted
  # and return to use just simpler received_testimonials named scopes
  def received_testimonials_in_community(person, community)
    person.received_testimonials.by_community(community)
  end
  def received_positive_testimonials_in_community(person, community)
    person.received_positive_testimonials.by_community(community)
  end
  def received_negative_testimonials_in_community(person, community)
    person.received_negative_testimonials.by_community(community)
  end
end
