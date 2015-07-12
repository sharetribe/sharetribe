require 'spec_helper'

describe PersonViewUtils do
  it "#display_name" do
    expect(PersonViewUtils.display_name(
      first_name: "John",
      last_name: "Doe",
      organization_name: "John D Inc.",
      username: "johnd",
      name_display_type: "first_name_with_initial",
      is_organization: false,
      is_deleted: true,
      deleted_user_text: "Deleted user")).to eql("Deleted user")

    expect(PersonViewUtils.display_name(
      first_name: "John",
      last_name: "Doe",
      organization_name: "John D Inc.",
      username: "johnd",
      name_display_type: "first_name_with_initial",
      is_organization: true,
      is_deleted: false,
      deleted_user_text: "Deleted user")).to eql("John D Inc.")

    expect(PersonViewUtils.display_name(
      first_name: "John",
      last_name: "Doe",
      organization_name: "John D Inc.",
      username: "johnd",
      name_display_type: "first_name_with_initial",
      is_organization: false,
      is_deleted: false,
      deleted_user_text: "Deleted user")).to eql("John D")

    expect(PersonViewUtils.display_name(
      first_name: "John",
      last_name: "Doe",
      organization_name: "John D Inc.",
      username: "johnd",
      name_display_type: "first_name_only",
      is_organization: false,
      is_deleted: false,
      deleted_user_text: "Deleted user")).to eql("John")

    expect(PersonViewUtils.display_name(
      first_name: "John",
      last_name: "Doe",
      organization_name: "John D Inc.",
      username: "johnd",
      name_display_type: "full_name",
      is_organization: false,
      is_deleted: false,
      deleted_user_text: "Deleted user")).to eql("John Doe")

    expect(PersonViewUtils.display_name(
      first_name: "John",
      last_name: "Doe",
      organization_name: "John D Inc.",
      username: "johnd",
      name_display_type: nil,
      is_organization: false,
      is_deleted: false,
      deleted_user_text: "Deleted user")).to eql("John D")

    expect(PersonViewUtils.display_name(
      first_name: nil,
      last_name: nil,
      organization_name: "John D Inc.",
      username: "johnd",
      name_display_type: "first_name_with_initial",
      is_organization: false,
      is_deleted: false,
      deleted_user_text: "Deleted user")).to eql("johnd")
  end

  it "#person_entity_display_name" do
    expect(PersonViewUtils.person_entity_display_name(nil, "full_name"))
      .to eql(I18n.translate("common.removed_user"))
  end

  it "#person_display_name" do
    expect(PersonViewUtils.person_display_name(nil, Community.first))
      .to eql(I18n.translate("common.removed_user"))
  end

end
