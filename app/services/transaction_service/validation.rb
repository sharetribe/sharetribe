module TransactionService
  module Validation

    IS_POSITIVE = ->(v) {
      return if v.nil?

      unless v.positive?
        {code: :positive_integer, msg: "Value must be a positive integer"}
      end
    }

    PARSE_DATE = ->(v) {
      return if v.nil?

      begin
        TransactionViewUtils.parse_booking_date(v)
      rescue ArgumentError => e
        # The transformator has to return something else than `Date` or
        # `nil` so that the `date` validator know that it's not a valid
        # date
        e
      end
    }

    PARSE_DATETIME = ->(v) {
      return if v.nil?

      begin
        TransactionViewUtils.parse_booking_datetime(v)
      rescue ArgumentError => e
        e
      end
    }

    NewTransactionParams = EntityUtils.define_builder(
      [:delivery, :to_symbol, one_of: [nil, :shipping, :pickup]],
      [:start_on, :date, transform_with: PARSE_DATE],
      [:end_on, :date, transform_with: PARSE_DATE],
      [:message, :string],
      [:quantity, :to_integer, validate_with: IS_POSITIVE],
      [:contract_agreed, transform_with: ->(v) { v == "1" }]
    )

    NewPerHourTransactionParams = EntityUtils.define_builder(
      [:delivery, :to_symbol, one_of: [nil, :shipping, :pickup]],
      [:start_time, :time, transform_with: PARSE_DATETIME],
      [:end_time, :time, transform_with: PARSE_DATETIME],
      [:per_hour, transform_with: ->(v) { v == "1" }],
      [:message, :string],
      [:contract_agreed, transform_with: ->(v) { v == "1" }]
    )

    module Validator

      module_function

      def validate_initiate_params(marketplace_uuid:,
                                   listing:,
                                   tx_params:,
                                   quantity_selector:,
                                   shipping_enabled:,
                                   pickup_enabled:,
                                   availability_enabled:,
                                   stripe_in_use:)

        validate_delivery_method(tx_params: tx_params, shipping_enabled: shipping_enabled, pickup_enabled: pickup_enabled)
          .and_then { validate_booking(tx_params: tx_params, quantity_selector: quantity_selector, stripe_in_use: stripe_in_use) }
          .and_then { |result|
            if availability_enabled
              validate_booking_timeslots(listing: listing, tx_params: tx_params)
            else
              Result::Success.new(result)
            end
        }
      end

      def validate_initiated_params(marketplace_uuid:,
                                    tx_params:,
                                    listing:,
                                    quantity_selector:,
                                    shipping_enabled:,
                                    pickup_enabled:,
                                    availability_enabled:,
                                    transaction_agreement_in_use:,
                                    stripe_in_use:)

        validate_delivery_method(tx_params: tx_params, shipping_enabled: shipping_enabled, pickup_enabled: pickup_enabled)
          .and_then { validate_booking(tx_params: tx_params, quantity_selector: quantity_selector, stripe_in_use: stripe_in_use) }
          .and_then { |result|
            # Dublication of initiate validation becouse of bug when use click
            # 'back' in browser after successfull payment and redirection to
            # dialog page, browser just render previous initiate page and if
            # user pay agian he create second transaction with same params & make payment
            if availability_enabled
              validate_booking_timeslots(listing: listing, tx_params: tx_params)
            else
              Result::Success.new(result)
            end
          }
          .and_then {
            validate_transaction_agreement(tx_params: tx_params,
                                           transaction_agreement_in_use: transaction_agreement_in_use)
          }
      end

      def validate_delivery_method(tx_params:, shipping_enabled:, pickup_enabled:)
        delivery = tx_params[:delivery]

        case [delivery, shipping_enabled, pickup_enabled]
        when matches([:shipping, true])
          Result::Success.new(tx_params.merge(delivery: :shipping))
        when matches([:pickup, __, true])
          Result::Success.new(tx_params.merge(delivery: :pickup))
        when matches([nil, false, false])
          Result::Success.new(tx_params.merge(delivery: :nil))
        else
          Result::Error.new(nil, code: :delivery_method_missing, tx_params: tx_params)
        end
      end

      def validate_booking(tx_params:, quantity_selector:, stripe_in_use:)
        per_hour = tx_params[:per_hour]
        if per_hour || [:day, :night].include?(quantity_selector)
          start_on, end_on = per_hour ? tx_params.values_at(:start_time, :end_time)  : tx_params.values_at(:start_on, :end_on)
          max_end_date = stripe_in_use ? APP_CONFIG.stripe_max_booking_date.days.from_now : 12.months.from_now

          if start_on.nil? || end_on.nil?
            Result::Error.new(nil, code: :dates_missing, tx_params: tx_params)
          elsif start_on > end_on
            Result::Error.new(nil, code: :end_cant_be_before_start, tx_params: tx_params)
          elsif start_on == end_on
            code = per_hour ? :at_least_one_hour_required : :at_least_one_day_or_night_required
            Result::Error.new(nil, code: code, tx_params: tx_params)
          elsif end_on > max_end_date
            Result::Error.new(nil, code: :date_too_late, tx_params: tx_params)
          else
            Result::Success.new(tx_params)
          end
        else
          Result::Success.new(tx_params)
        end
      end

      def all_days_available(timeslots, start_on, end_on)
        # Take all the days except the exclusive last day
        requested_days = (start_on..end_on).to_a[0..-2]

        available_days = timeslots
                           .select { |s| s[:unitType] == :day }
                           .map { |s| s[:start].to_date }

        requested_days.all? { |d|
          available_days.include?(d)
        }
      end

      def validate_booking_timeslots(listing:, tx_params:)
        booking_params = if tx_params[:per_hour]
                           tx_params.slice(:start_time, :end_time, :per_hour)
                         else
                           tx_params.slice(:start_on, :end_on)
                         end

        booking = Booking.new(
          booking_params.merge(
          tx: ::Transaction.new(listing: listing))
        )
        if booking.valid?
          Result::Success.new(tx_params)
        else
          Result::Error.new(nil, code: :dates_not_available)
        end
      end

      def validate_transaction_agreement(tx_params:, transaction_agreement_in_use:)
        contract_agreed = tx_params[:contract_agreed]

        if transaction_agreement_in_use
          if contract_agreed
            Result::Success.new(tx_params)
          else
            Result::Error.new(nil, code: :agreement_missing, tx_params: tx_params)
          end
        else
          Result::Success.new(tx_params)
        end
      end
    end
  end
end
