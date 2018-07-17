Given(/^there is a person custom field "(.*?)" in community "(.*?)"$/) do |name, community|
  current_community = Community.where(ident: community).first
  @custom_field = FactoryGirl.build(:person_custom_dropdown_field, {
    community_id: current_community.id,
    names: [CustomFieldName.create(value: name, locale: "en")],
    sort_priority: @person_custom_field_sort_priority
  })
  @custom_field.save
  @person_custom_field_sort_priority ||= 0
  @person_custom_field_sort_priority += 1
end

def create_person_custom_field_with_options(field_type, required, name, community, options)
  current_community = Community.where(ident: community).first
  custom_field = FactoryGirl.build(field_type, {
    community_id: current_community.id,
    names: [CustomFieldName.create(value: name, locale: "en")],
    required: required,
    sort_priority: @person_custom_field_sort_priority
  })

  custom_field.options << options.hashes.each_with_index.map do |hash, index|
    en = FactoryGirl.build(:custom_field_option_title, value: hash['fi'], locale: 'fi')
    fi = FactoryGirl.build(:custom_field_option_title, value: hash['en'], locale: 'en')
    FactoryGirl.build(:custom_field_option, titles: [en, fi], sort_priority: index)
  end

  custom_field.save!
  @person_custom_field_sort_priority ||= 0
  @person_custom_field_sort_priority += 1

  @custom_fields ||= []
  @custom_fields << custom_field
end

Given(/^there is a( required)? person custom dropdown field "(.*?)" in community "(.*?)" with options:$/) do |required, name, community, options|
  create_person_custom_field_with_options(:person_custom_dropdown_field, required, name, community, options)
end

Given(/^there is a( required)? person custom checkbox field "(.*?)" in community "(.*?)" with options:$/) do |required, name, community, options|
  create_person_custom_field_with_options(:person_custom_checkbox_field, required, name, community, options)
end

Given(/^there is a( required)?( public)? person custom text field "(.*?)" in community "(.*?)"$/) do |required, is_public, name, community|
  current_community = Community.where(ident: community).first
  custom_field = FactoryGirl.build(:person_custom_text_field, {
    :community_id => current_community.id,
    :names => [CustomFieldName.create(:value => name, :locale => "en")],
    :required => required,
    :public => is_public,
    sort_priority: @person_custom_field_sort_priority
  })

  custom_field.save!
  @person_custom_field_sort_priority ||= 0
  @person_custom_field_sort_priority += 1

  @custom_fields ||= []
  @custom_fields << custom_field
end

Given(/^there is a( required)? person custom numeric field "(.*?)" in community "(.*?)"$/) do |required, name, community|
  current_community = Community.where(ident: community).first
  custom_field = FactoryGirl.build(:person_custom_numeric_field, {
    :community_id => current_community.id,
    :names => [CustomFieldName.create(:value => name, :locale => "en")],
    :required => required,
    sort_priority: @person_custom_field_sort_priority
  })

  custom_field.save!
  @person_custom_field_sort_priority ||= 0
  @person_custom_field_sort_priority += 1

  @custom_fields ||= []
  @custom_fields << custom_field
end

Given(/^there is a( required)? person custom date field "(.*?)" in community "(.*?)"$/) do |required, name, community|
  current_community = Community.where(ident: community).first
  custom_field = FactoryGirl.build(:person_custom_date_field, {
    :community_id => current_community.id,
    :names => [CustomFieldName.create(:value => name, :locale => "en")],
    :required => required,
    sort_priority: @person_custom_field_sort_priority
  })

  custom_field.save!
  @person_custom_field_sort_priority ||= 0
  @person_custom_field_sort_priority += 1

  @custom_fields ||= []
  @custom_fields << custom_field
end

