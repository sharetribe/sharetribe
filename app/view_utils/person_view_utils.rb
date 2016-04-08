module PersonViewUtils
  module_function

  # This method is an adapter to `display_name` method.
  # Makes the use easier by allowing Person and Community models as parameters
  def person_display_name(person, community)
    if person.nil?
      display_name(
        first_name: nil,
        last_name: nil,
        organization_name: nil,
        username: nil,
        name_display_type: nil,
        is_organization: false,
        is_deleted: true,
        deleted_user_text: I18n.translate("common.removed_user")
      )
    else
      display_name(
        first_name: person.given_name,
        last_name: person.family_name,
        username: person.username,

        name_display_type: community.name_display_type,

        is_organization: person.is_organization?,
        organization_name: person.organization_name,

        is_deleted: person.deleted?,
        deleted_user_text: I18n.translate("common.removed_user")
      )
    end
  end

  # This is another adapter to `display_name`.
  # It accepts person entity
  def person_entity_display_name(person_entity, name_display_type)
    if person_entity.nil?
      display_name(
        first_name: nil,
        last_name: nil,
        organization_name: nil,
        username: nil,
        name_display_type: name_display_type,
        is_organization: false,
        is_deleted: true,
        deleted_user_text: I18n.translate("common.removed_user")
      )
    else
      display_name(
        first_name: person_entity[:first_name],
        last_name: person_entity[:last_name],
        organization_name: person_entity[:organization_name],
        username: person_entity[:username],
        name_display_type: name_display_type,
        is_organization: person_entity[:is_organization],
        is_deleted: person_entity[:is_deleted],
        deleted_user_text: I18n.translate("common.removed_user")
      )
    end
  end

  # rubocop:disable ParameterLists
  def display_name(
        first_name:,
        last_name:,
        organization_name:,
        username:,
        name_display_type:,
        is_organization:,
        is_deleted:,
        deleted_user_text:)
    name_present = first_name.present?

    case [is_deleted, is_organization, name_present, name_display_type]
    when matches([true])
      deleted_user_text
    when matches([__, true])
      organization_name
    when matches([__, __, true, "first_name_with_initial"])
      first_name_with_initial(first_name, last_name)
    when matches([__, __, true, "first_name_only"])
      first_name
    when matches([__, __, true, "full_name"])
      full_name(first_name, last_name)
    when matches([__, __, true])
      first_name_with_initial(first_name, last_name)
    else
      username
    end
  end
  # rubocop:enable ParameterLists

  def full_name(first_name, last_name)
    "#{first_name} #{last_name}"
  end

  def first_name_with_initial(first_name, last_name)
    if last_name.present?
      "#{first_name} #{last_name[0, 1]}"
    else
      first_name
    end
  end
end
