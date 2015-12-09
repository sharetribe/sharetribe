module BackgroundCheckContainersHelper

  def get_field_type
    [
      ['Text Field', 'textfield'],
      ['Text Area', 'textarea'],
      ['File', 'file']
    ]
  end

  def status_bg_color
    [
      ['Yellow', 'yellow'],
      ['Green', 'green'],
      ['Red', 'red']
    ]
  end

  def get_background_check_field bcc
    case bcc.container_type
    when 'textfield'
      text_field_tag bcc.name, get_person_background_check_value(@person, bcc.id), placeholder: bcc.placeholder_text, name: "background_check_container[1,#{bcc.id}]", disabled: bcc.active ? false : true
    when 'textarea'
      text_area_tag bcc.name, get_person_background_check_value(@person, bcc.id), placeholder: bcc.placeholder_text, name: "background_check_container[1,#{bcc.id}]]", disabled: bcc.active ? false : true
    when 'file'
      file_field_tag bcc.name, id: "real_btn_#{bcc.id}", name: "background_check_container[2,#{bcc.id}]", style: 'display:none;', disabled: bcc.active ? false : true
    end
  end

  def get_person_background_check_value person, bcc_id
    person_background_check = person.person_background_checks.where(background_check_container_id: bcc_id).first
    background_check_container = BackgroundCheckContainer.find(bcc_id)
    if person_background_check.nil?
      background_check_container.container_type == 'file' ? nil : ''
    else
      case  background_check_container.container_type
      when 'textfield' || 'textarea'
        person_background_check.value
      when 'file'
        # person_background_check.document
        person_background_check
      end
    end
  end

  def get_person_status person, bcc_id
    person_background_checks = person.person_background_checks.where(background_check_container_id: bcc_id).first
    if person_background_checks.nil?
      []
    else
      person_background_checks.status_ids
    end
  end

  def get_status status_id
    BccStatus.find(status_id)
  end
end
