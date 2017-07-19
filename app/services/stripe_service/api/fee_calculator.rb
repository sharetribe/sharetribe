module StripeService
  module API
    module FeeCalculator
      # Grabbed from pages like https://stripe.com/us/pricing
      PRICING = {
        AT: "1.4% + €0.25 for European cards. 2.9% + €0.25 for non-European cards.",
        BE: "1.4% + €0.25 for European cards. 2.9% + €0.25 for non-European cards.",
        CA: "2.9% + C$0.30 per successful card charge",
        CH: "2.9% + 0.30Fr per successful card charge",
        DE: "1.4% + €0.25 for European cards. 2.9% + €0.25 for non-European cards.",
        DK: "1.4% + 1.80kr for European cards. 2.9% + 1.80kr for non-European cards.",
        ES: "1.4% + €0.25 for European cards. 2.9% + €0.25 for non-European cards.",
        FI: "1.4% + €0.25 for European cards. 2.9% + €0.25 for non-European cards.",
        FR: "1.4% + €0.25 for European cards. 2.9% + €0.25 for non-European cards.",
        GB: "1.4% + 20p for European cards. 2.9% + 20p for non-European cards.",
        IE: "1.4% + €0.25 for European cards excluding VAT. 2.9% + €0.25 for non-European cards excluding VAT.",
        IT: "1.4% + €0.25 for European cards. 2.9% + €0.25 for non-European cards.",
        LU: "1.4% + €0.25 for European cards. 2.9% + €0.25 for non-European cards.",
        NL: "1.4% + €0.25 for European cards. 2.9% + €0.25 for non-European cards.",
        NO: "2.4% + 2kr for Norwegian cards. 2.9% + 2kr for International cards.",
        PT: "1.4% + €0.25 for European cards. 2.9% + €0.25 for non-European cards.",
        SE: "1.4% + 1.80kr for European cards. 2.9% + 1.80kr for non-European cards.",
        US: "2.9% + 30¢ per successful card charge",
      }

      DEFAULT_CURRENCIES = {
        AT: "eur",
        BE: "eur",
        CA: "cad",
        CH: "chf",
        DE: "eur",
        DK: "dkk",
        ES: "eur",
        FI: "eur",
        FR: "eur",
        GB: "gbp",
        IE: "eur",
        IT: "eur",
        LU: "eur",
        NL: "eur",
        NO: "nok",
        PT: "eur",
        SE: "sek",
        US: "usd"
      }

      module_function

      def parsed(country)
        rule_text = PRICING[country.to_sym]
        parts = rule_text.split(/cards\. |VAT\. /, 2)
        data = parts.map do |one_rule|
          card_type = case one_rule
                      when /for European/       then :europe
                      when /for non-European/   then :noneurope
                      when /for International/  then :world
                      when /for domestic/       then country.to_sym
                      when /for Norwegian/      then country.to_sym
                      else
                        :any
                      end
          fixed_cost = one_rule[/\+[^0-9]+([0-9.]+)/].to_f
          fixed_cost = fixed_cost > 10 ? fixed_cost / 100.0 : fixed_cost
          {
            currency: DEFAULT_CURRENCIES[country.to_sym],
            percent: one_rule[/^[0-9.]+%/].to_f,
            fixed: fixed_cost,
            card_type: card_type,
            vat: !!(rule_text =~ /VAT/)
          }
        end
        { country.to_sym => data }
      end

      # Generated from plain text pricing rules
      PARSED_PRICING = {
        AT: [{currency: "eur", percent: 1.4,  fixed: 0.25, card_type: :europe}, {currency: "eur", percent: 2.9, fixed: 0.25, card_type: :noneurope}],
        BE: [{currency: "eur", percent: 1.4,  fixed: 0.25, card_type: :europe}, {currency: "eur", percent: 2.9, fixed: 0.25, card_type: :noneurope}],
        CA: [{currency: "cad", percent: 2.9,  fixed: 0.3,  card_type: :any}],
        CH: [{currency: "chf", percent: 2.9,  fixed: 0.3,  card_type: :any}],
        DE: [{currency: "eur", percent: 1.4,  fixed: 0.25, card_type: :europe}, {currency: "eur", percent: 2.9, fixed: 0.25, card_type: :noneurope}],
        DK: [{currency: "dkk", percent: 1.4,  fixed: 1.8,  card_type: :europe}, {currency: "dkk", percent: 2.9, fixed: 1.8,  card_type: :noneurope}],
        ES: [{currency: "eur", percent: 1.4,  fixed: 0.25, card_type: :europe}, {currency: "eur", percent: 2.9, fixed: 0.25, card_type: :noneurope}],
        FI: [{currency: "eur", percent: 1.4,  fixed: 0.25, card_type: :europe}, {currency: "eur", percent: 2.9, fixed: 0.25, card_type: :noneurope}],
        FR: [{currency: "eur", percent: 1.4,  fixed: 0.25, card_type: :europe}, {currency: "eur", percent: 2.9, fixed: 0.25, card_type: :noneurope}],
        GB: [{currency: "gbp", percent: 1.4,  fixed: 0.2,  card_type: :europe}, {currency: "gbp", percent: 2.9, fixed: 0.2,  card_type: :noneurope}],
        IE: [{currency: "eur", percent: 1.4,  fixed: 0.25, card_type: :europe, vat: true}, {currency: "eur", percent: 2.9, fixed: 0.25, card_type: :noneurope, vat: true}],
        IT: [{currency: "eur", percent: 1.4,  fixed: 0.25, card_type: :europe}, {currency: "eur", percent: 2.9, fixed: 0.25, card_type: :noneurope}],
        LU: [{currency: "eur", percent: 1.4,  fixed: 0.25, card_type: :europe}, {currency: "eur", percent: 2.9, fixed: 0.25, card_type: :noneurope}],
        NL: [{currency: "eur", percent: 1.4,  fixed: 0.25, card_type: :europe}, {currency: "eur", percent: 2.9, fixed: 0.25, card_type: :noneurope}],
        NO: [{currency: "nok", percent: 2.4,  fixed: 2.0,  card_type: :NO},     {currency: "nok", percent: 2.9, fixed: 2.0,  card_type: :world}],
        PT: [{currency: "eur", percent: 1.4,  fixed: 0.25, card_type: :europe}, {currency: "eur", percent: 2.9, fixed: 0.25, card_type: :noneurope}],
        SE: [{currency: "sek", percent: 1.4,  fixed: 1.8,  card_type: :europe}, {currency: "sek", percent: 2.9, fixed: 1.8,  card_type: :noneurope}],
        US: [{currency: "usd", percent: 2.9,  fixed: 0.3,  card_type: :any}],
      }

      EUROPE_COUNTRIES = %i(AT BE CH DE DK ES FI FR GB IE IT LU NL PT SE)

      def card_types(card_country)
        types = []
        types << card_country.to_sym
        types << EUROPE_COUNTRIES.include?(card_country.to_sym) ? :europe : :noneurope
        types << :world
        types << :any
      end

      def fee_rule(merchant_country, card_country)
        types = card_types card_country.to_sym
        rules = PARSED_PRICING[merchant_country.to_sym]
        rule = rules.detect do |one_rule|
          types.include?(one_rule[:card_type])
        end
      end

      # https://support.stripe.com/questions/can-i-charge-my-stripe-fees-to-my-customers
      def total_with_fee(goal_total, merchant_country, card_country)
        rule = fee_rule merchant_country, card_country

        # NOTE: if order currency is different from seller default currency (e.g. from German/EUR sell for USD),
        # we cannot calculate fixed part without exchange rates so some loss can be here
        f_fixed = goal_total.currency.iso_code.downcase != rule[:currency] ? Money.new(0, goal_total.currency) :  Money.new(rule[:fixed] * 100, goal_total.currency)

        f_percent = rule[:percent] / 100.0
        if rule[:vat] && merchat_country == 'IE' # currently for Ireland only
          scale = 1.23
          p_charge = (goal_total + f_fixed * scale) / (1 - f_percent)
        else
          p_charge = (goal_total + f_fixed) / (1 - f_percent)
        end
        p_charge
      end
    end
  end
end
