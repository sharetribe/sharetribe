module PersonHelper
  module_function

  def ensure_person_belongs_to_current_community!(person, community)
    raise ActiveRecord::RecordNotFound.new('Not Found') unless @person.communities.include?(community)
  end
end
