module ListingShapeProcessViewUtils

  module_function

  def available_templates(templates, process_info)
    templates.reject { |tmpl|
      tmpl[:shape][:template] == :requesting && !process_info[:request_available]
    }.map { |tmpl|
      process_template(tmpl, process_info)
    }
  end

  def find_template(key, templates, process_info)
    available_templates(templates, process_info).find { |tmpl| tmpl[:shape][:template] == key.to_sym }
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
    shape[:shipping_enabled] = false unless process_info[:preauthorize_available]
    shape[:online_payments] = false unless process_info[:preauthorize_available] || process_info[:postpay_available]
    shape
  end

  def uneditable_fields(process_info)
    {
      shipping_enabled: !process_info[:preauthorize_available],
      online_payments: !(process_info[:preauthorize_available] || process_info[:postpay_available])
    }
  end

  def process_info(processes)
    processes.reduce({}) { |info, process|
      info[:request_available] = true if process[:author_is_seller] == false
      info[:preauthorize_available] = true if process[:process] == :preauthorize
      info
    }
  end

  module ShapeSanitizer

    PROCESS_AVAILABLE = ->(shape, processes) {
      process_find_opts = shape[:transaction_process].slice(:author_is_seller, :process)
      process = processes.find { |p|
        p.slice(*process_find_opts.keys) == process_find_opts
      }

      if process
        Result::Success.new(shape)
      else
        Result::Error.new("Suitable transaction process not available", code: "suitable_process_not_available")
      end
    }

    PRICE_ENABLED_IF_ONLINE_PAYMENTS = ->(shape, process_summary) {
      case [shape[:price_enabled], shape[:transaction_process][:process]]
      when matches([true, :preauthorize]), matches([true, :postpay])
        Result::Success.new(shape)
      when matches([__, :none])
        Result::Success.new(shape)
      else
        Result::Error.new("Price must be enabled if online payments is in use", code: "price_enabled_if_payments")
      end
    }

    PREAUTHORIZE_IF_SHIPPING = ->(shape, process_summary) {
      case [shape[:shipping_enabled], shape[:transaction_process][:process]]
      when matches([false])
        Result::Success.new(shape)
      when matches([true, :preauthorize])
        Result::Success.new(shape)
      else
        Result::Error.new("Shipping is available only for preauthorized payment process", code: "preauthorize_enabled_if_shipping")
      end
    }

    PRICE_ENABLED_IF_UNITS = ->(shape, process_summary) {
      case [shape[:price_enabled], shape[:units].present?]
      when matches([true])
        Result::Success.new(shape)
      when matches([false, false])
        Result::Success.new(shape)
      else
        Result::Error.new("Price must be enabled if units are in use", code: "price_enabled_if_units")
      end
    }

    PRICE_DISABLED_IF_AUTHOR_IS_NOT_SELLER = ->(shape, process_summary) {
      case [shape[:price_enabled], shape[:transaction_process][:author_is_seller]]
      when matches([true, false])
        Result::Error.new("Price must be disabled if author is not the seller", code: "price_disabled_if_author_is_not_seller")
      else
        Result::Success.new(shape)
      end
    }

    PROCESS_MUST_BE_NONE_IF_AUTHOR_IS_NOT_SELLER = ->(shape, process_summary) {
      case [shape[:transaction_process][:author_is_seller], shape[:transaction_process][:process]]
      when matches([false, :none]), matches([true])
        Result::Success.new(shape)
      else
        Result::Error.new("Process must be none if author is not seller", code: "process_none_if_author_is_not_seller")
      end
    }

    module_function

    def sanitize(shape, process_summary)
      shape.merge(
        shipping_enabled: process_summary[:preauthorize_available] ? shape[:shipping_enabled] : false,
      )
    end

    def validate(shape, process_summary, validators = nil)
      validators ||= [
        PROCESS_AVAILABLE,
        PRICE_ENABLED_IF_ONLINE_PAYMENTS,
        PREAUTHORIZE_IF_SHIPPING,
        PRICE_ENABLED_IF_UNITS,
        PRICE_DISABLED_IF_AUTHOR_IS_NOT_SELLER,
        PROCESS_MUST_BE_NONE_IF_AUTHOR_IS_NOT_SELLER
      ]

      validators.reduce(Result::Success.new(shape)) { |res, validator|
        res.and_then { |shape| validator.call(shape, process_summary) }
      }
    end
  end
end
