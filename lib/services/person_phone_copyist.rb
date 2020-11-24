#
# As person's phone_number goes to custom fields this will
# 1) Create TextField with assignment phone_number for each community
# 2) will copy phone numbers of all persons into TextFieldValue
#
class PersonPhoneCopyist
  class << self
    def copy_all_communities
      Community.find_each do |community|
        copy_community(community)
      end
    end

    def copy_community(community)
      phone_field = first_or_create_phone_field(community)
      copy_all_persons(community, phone_field)
    end

    def copy_all_persons(community, phone_field)
      community.members.find_each do |person|
        copy_person(phone_field, person)
      end
    end

    def copy_person(phone_field, person)
      existing_value = person.custom_field_values.merge(CustomField.phone_number).first
      unless existing_value
        TextFieldValue.create(
          question: phone_field,
          text_value: person.phone_number,
          person: person
        )
      end
    end

    def first_or_create_phone_field(community)
      phone_field = community.person_custom_fields.phone_number.first
      if phone_field
        phone_field
      else
        names = {}
        locales = community.settings['locales'] || ['en']
        locales.each do |locale|
          names[locale] = I18n.t('settings.profile.phone_number')
        end
        field = TextField.new(
          entity_type: :for_person,
          assignment: :phone_number,
          name_attributes: names,
          required: false,
          public: false,
          sort_priority: 0
        )
        community.person_custom_fields << field
        field
      end
    end
  end
end
