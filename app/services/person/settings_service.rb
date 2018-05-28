class Person::SettingsService
  attr_reader :community, :params

  def initialize(community:, params:)
    @params = params
    @community = community
  end

  delegate :person_custom_fields, to: :community, prefix: true

  def person
    @person ||= Person.find_by!(username: params[:person_id], community_id: community.id)
  end

  def image_is_processing?
    person.image.processing?
  end

  def add_location_to_person
    unless person.location
      person.build_location(:address => person.street_address)
      person.location.search_and_fill_latlng
    end
    person
  end

  def custom_field_values
    @custom_field_values ||= build_custom_field_values
  end

  def has_person_custom_fields?
    community_person_custom_fields.any?
  end

  def new_person
    @person ||= if params[:person]
      Person.new(params[:person].slice(:given_name, :family_name, :email, :username).permit!)
    else
      Person.new()
    end
  end

  private

  def new_custom_field_value(custom_field)
    klass = "#{custom_field.class.name}Value".constantize
    klass.new(question: custom_field, person: person)
  end

  def build_custom_field_values
    values = person.custom_field_values
    community_person_custom_fields.each do |custom_field|
      exists = values.find{|value| value.custom_field_id == custom_field.id }
      unless exists
        values << new_custom_field_value(custom_field)
      end
    end
    values.sort_by{|x| x.sort_priority }
  end
end
