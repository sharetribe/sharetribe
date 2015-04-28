module ListingShapeProcessViewUtils

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
      when matches([true, :preauthorize])
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

    def sanitize(*)
      raise NotImplementedError.new("Sanitize is not implemented")
    end

    def validate(shape, process_summary, validators = nil)
      validators ||= [
        PROCESS_AVAILABLE,
        PRICE_ENABLED_IF_ONLINE_PAYMENTS,
        PREAUTHORIZE_IF_SHIPPING,
        PRICE_ENABLED_IF_UNITS,
        # PRICE_DISABLED_IF_AUTHOR_IS_NOT_SELLER,
        PROCESS_MUST_BE_NONE_IF_AUTHOR_IS_NOT_SELLER
      ]

      validators.reduce(Result::Success.new(shape)) { |res, validator|
        res.and_then { |shape| validator.call(shape, process_summary) }
      }
    end
  end
end
