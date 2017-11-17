module ListingAvailabilityManage
  def availability_enabled
    listing.availability.to_sym == :booking
  end

  def booking_dates_start
    1.day.ago.to_date
  end

  def booking_dates_end
    if stripe_in_use
      APP_CONFIG.stripe_max_booking_date.days.from_now.to_date
    else
      12.months.from_now.to_date
    end
  end

  def blocked_dates_result
    if availability_enabled

      get_blocked_dates(
        start_on: booking_dates_start,
        end_on: booking_dates_end,
        community: current_community,
        user: @current_user,
        listing: listing)
    else
      Result::Success.new([])
    end
  end

  def booking_dates_end_midnight
    DateUtils.to_midnight_utc(booking_dates_end)
  end

  def get_blocked_dates(start_on:, end_on:, community:, user:, listing:)
    HarmonyClient.get(
      :query_timeslots,
      params: {
        marketplaceId: community.uuid_object,
        refId: listing.uuid_object,
        start: start_on,
        end: end_on
      }
    ).rescue {
      Result::Error.new(nil, code: :harmony_api_error)
    }.and_then { |res|
      available_slots = dates_to_ts_set(
        res[:body][:data].map { |timeslot| timeslot[:attributes][:start].to_date }
      )
      Result::Success.new(
        dates_to_ts_set(start_on..end_on).subtract(available_slots)
      )
    }
  end

  def dates_to_ts_set(dates)
    Set.new(dates.map { |d| DateUtils.to_midnight_utc(d) })
  end

  def datepicker_localized_dates
    days = [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
    months = [:january, :february, :march, :april, :may, :june, :july, :august, :september, :october, :november, :december]
    translated_days = days.map { |day_symbol| I18n.t("datepicker.days.#{day_symbol}") }
    translated_days_short = days.map { |day_symbol| I18n.t("datepicker.days_short.#{day_symbol}") }
    translated_days_min = days.map { |day_symbol| I18n.t("datepicker.days_min.#{day_symbol}") }
    translated_months = months.map { |day_symbol| I18n.t("datepicker.months.#{day_symbol}") }
    translated_months_short = months.map { |day_symbol| I18n.t("datepicker.months_short.#{day_symbol}") }
    {
      days: translated_days,
      daysShort: translated_days_short,
      daysMin: translated_days_min,
      months: translated_months,
      monthsShort: translated_months_short,
      today: I18n.t("datepicker.today"),
      weekStart: I18n.t("datepicker.week_start", default: 0),
      clear: I18n.t("datepicker.clear"),
      format: I18n.t("datepicker.format")
    }
  end

  def datepicker_per_day_or_night_setup(blocked_dates)
    {
      locale: I18n.locale,
      localized_dates: datepicker_localized_dates,
      listing_quantity_selector: listing.quantity_selector,
      blocked_dates: blocked_dates.map { |d| d.to_i },
      end_date: booking_dates_end_midnight.to_i,
    }
  end

  def booking_per_hour_start_time
    date_to_time_utc(booking_dates_start)
  end

  def booking_per_hour_end_time
    date_to_time_utc(booking_dates_end + 1.day)
  end

  def availability_per_hour_options_for_select_grouped_by_day(start_time:, end_time:)
    return @availability_per_hour_options_for_select if defined?(@availability_per_hour_options_for_select)
    result = {}
    working_periods = listing.working_hours_periods_grouped_by_day(start_time, end_time)
    bookings = listing.working_hours_bookings_grouped_by_day(start_time, end_time)
    working_periods.each do |period_date, day_working_entries|
      start = nil
      day_result = []
      day_bookings = bookings[period_date]
      day_working_entries.each do |working_period|
        start = working_period.start_time
        while start < working_period.end_time do # rubocop:disable Style/WhileUntilDo
          hour_is_booked = day_bookings && day_bookings.select{ |booking| booking.start_time <= start && booking.end_time > start }.any?
          value = start.strftime('%H:%M')
          format = I18n.locale == :en ? '%l:%M %P' : '%H:%M'
          name = start.strftime(format)
          if !hour_is_booked
            day_result.push(value: value, name: name)
          else
            day_result.push(value: value, name: name, disabled: true)
          end
          start += 1.hour
        end
      end
      result[period_date] = day_result
    end
    @availability_per_hour_options_for_select = result
  end

  def availability_per_hour_blocked_dates(start_time:, end_time:)
    result = []
    bookings_per_day_summary = listing.bookings_per_hour.in_period(start_time, end_time).per_day_summary
    periods = listing.working_hours_periods_grouped_by_day(start_time, end_time.at_end_of_day)
    index_day = start_time.to_date
    end_day = end_time.to_date
    while index_day <= end_day do # rubocop:disable Style/WhileUntilDo
      period_date = index_day.to_s
      period_time_slots = periods[period_date]
      working_time_in_seconds = period_time_slots ? period_time_slots.map{|t| t.end_time - t.start_time}.sum.to_i : 0
      if working_time_in_seconds == 0
        result.push index_day
      else
        day_summary = bookings_per_day_summary.to_a.select do |summary|
          summary.start_date == index_day
        end.first
        if day_summary && day_summary.day_summary_time == working_time_in_seconds
          result.push index_day
        end
      end
      index_day += 1.day
    end
    result
  end

  def datepicker_per_hour_setup(start_time: booking_per_hour_start_time, end_time: booking_per_hour_end_time)
    {
      locale: I18n.locale,
      localized_dates: datepicker_localized_dates,
      listing_quantity_selector: listing.quantity_selector,
      blocked_dates: availability_per_hour_blocked_dates(start_time: start_time, end_time: end_time).map { |d| date_to_time_utc(d).to_i },
      end_date: booking_dates_end_midnight.to_i,
      options_for_select: availability_per_hour_options_for_select_grouped_by_day(start_time: start_time, end_time: end_time),
    }
  end

  def working_hours_props
    {
      i18n: {
        locale: I18n.locale,
        default_locale: I18n.default_locale,
        locale_info: I18nHelper.locale_info(Sharetribe::AVAILABLE_LOCALES, I18n.locale)
      },
      marketplace: {
        uuid: @current_community.uuid_object.to_s,
        marketplace_color1: CommonStylesHelper.marketplace_colors(@current_community)[:marketplace_color1],
      },
      listing: working_time_slots,
      time_slot_options: time_slot_options,
      day_names: day_names,
      listing_just_created: !!params[:listing_just_created],
      first_day_of_week: I18n.t('date.first_day_of_week')
    }
  end

  def booking_per_hour?
    listing.listing_shape&.booking_per_hour?
  end

  def quantity_per_day_or_night?
    [:day, :night].include?(listing.quantity_selector&.to_sym)
  end

  private

  def working_time_slots
    listing.working_hours_new_set
    listing.working_hours_as_json
  end

  def time_slot_options
    result = []
    (0..24).each do |x|
      value = format("%02d:00", x)
      name = I18n.locale == :en ? Time.parse("#{x}:00").strftime("%l:00 %P") : value # rubocop:disable Rails/TimeZone
      result.push(value: value, label: name)
    end
    result
  end

  def date_to_time_utc(d)
    Time.utc(d.year, d.month, d.day)
  end

  def day_names
    result = {}
    i18n_day_names = I18n.t('date.day_names').map(&:capitalize)
    ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'].each_with_index do |day, index|
      result[day] = i18n_day_names[index]
    end
    result
  end
end
