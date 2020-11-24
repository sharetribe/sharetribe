module PersonViewUtils
  module_function

  # This method is an adapter to `display_name` method.
  # Makes the use easier by allowing Person and Community models as parameters
  def person_display_name(person, community)
    person_display_names(person, community).join(" ")
  end

  def person_display_names(person, community)
    person_display_names_for_type(person, community.name_display_type)
  end

  def person_display_name_for_type(person, name_display_type)
    person_display_names_for_type(person, name_display_type).join(" ")
  end

  def person_display_names_for_type(person, name_display_type)
    if person.nil?
      names(
        first_name: nil,
        last_name: nil,
        display_name: nil,
        username: nil,
        name_display_type: nil,
        is_deleted: true,
        deleted_user_text: I18n.translate("common.removed_user")
      )
    else
      names(
        first_name: person.given_name,
        last_name: person.family_name,
        display_name: person.display_name,
        username: person.username,

        name_display_type: name_display_type,

        is_deleted: person.deleted?,
        deleted_user_text: I18n.translate("common.removed_user")
      )
    end
  end

  # This is another adapter to `display_name`.
  # It accepts person entity
  def person_entity_display_name(person_entity, name_display_type)
    person_entity_display_names(person_entity, name_display_type).join(" ")
  end

  def person_entity_display_names(person_entity, name_display_type)
    if person_entity.nil?
      names(
        first_name: nil,
        last_name: nil,
        display_name: nil,
        username: nil,
        name_display_type: name_display_type,
        is_deleted: true,
        deleted_user_text: I18n.translate("common.removed_user")
      )
    else
      names(
        first_name: person_entity[:first_name],
        last_name: person_entity[:last_name],
        display_name: person_entity[:display_name],
        username: person_entity[:username],
        name_display_type: name_display_type,
        is_deleted: person_entity[:is_deleted],
        deleted_user_text: I18n.translate("common.removed_user")
      )
    end
  end

  def names(
        first_name:,
        last_name:,
        display_name:,
        username:,
        name_display_type:,
        is_deleted:,
        deleted_user_text:
        )
    name_present = first_name.present?
    display_name_present = display_name.present?

    case [is_deleted, name_present, display_name_present, name_display_type]
    when matches([true])
      [deleted_user_text]
    when matches([__, __, true])
      [display_name]
    when matches([__, true, __, "first_name_with_initial"])
      first_name_with_initial(first_name, last_name)
    when matches([__, true, __, "first_name_only"])
      [first_name]
    when matches([__, true, __, "full_name"])
      full_name(first_name, last_name)
    when matches([__, true])
      first_name_with_initial(first_name, last_name)
    else
      [username]
    end
  end

  def display_name(
        first_name:,
        last_name:,
        display_name:,
        username:,
        name_display_type:,
        is_deleted:,
        deleted_user_text:
        )
    names(first_name: first_name,
          last_name: last_name,
          display_name: display_name,
          username: username,
          name_display_type: name_display_type,
          is_deleted: is_deleted,
          deleted_user_text: deleted_user_text).join(" ")
  end

  def full_name(first_name, last_name)
    [first_name.to_s, last_name.to_s]
  end

  def first_name_with_initial(first_name, last_name)
    if last_name.present?
      [first_name.to_s, last_name[0, 1].to_s]
    else
      [first_name]
    end
  end
end
