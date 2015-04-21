module ListingShapeProcessViewUtils

  module_function

  def available_templates(templates, process_info)
    templates.reject { |tmpl|
      tmpl[:key] == :requesting && !process_info[:request_available]
    }.map { |tmpl|
      process_template(tmpl, process_info)
    }
  end

  def find_template(key, templates, process_info)
    available_templates(templates, process_info).find { |tmpl| tmpl[:key] == key.to_sym }
  end

  def process_shape(shape, process_info, template = {})
    template.merge(
      map_process_required_values(
        reject_uneditable_fields(shape, process_info),
        process_info
      )
    )
  end

  def process_template(template, process_info)
    process_shape({}, process_info, template)
  end

  def reject_uneditable_fields(shape, process_info)
    uneditable = uneditable_fields(process_info)
    shape = shape.reject { |k, _|
      uneditable[k]
    }
  end

  def map_process_required_values(shape, process_info)
    shape[:shipping_enabed] = false unless process_info[:preauthorize_available]
    shape[:online_payments] = false unless process_info[:preauthorize_available]
    shape
  end

  def uneditable_fields(process_info)
    {
      author_is_seller: true, # can not edit
      shipping_enabled: process_info[:preauthorize_available],
      online_payments: process_info[:preauthorize_available]
    }
  end

  def process_info(processes)
    processes.reduce({}) { |info, process|
      info[:request_available] = true if process[:author_is_seller] == false
      info[:preauthorize_available] = true if process[:process] == :preauthorize
      info
    }
  end
end
