module PaymentsHelper
  TEST_IBAN = '89370400440532013000'

  BANK_RULES = {
    AU: {
      account_number: { format: 'format_varies_by_bank', regexp: '[0-9]{6,10}', test_regexp: '[0-9]{6,10}'},
      routing_number: { title: 'bsb',  format: '123456', regexp: '[0-9]{6}', test_regexp: '[0-9]{6}'},
      phone_number: '+61 2 1234 0000'
    },
    AT: {
      account_number: { title: 'IBAN', format: 'AT611904300235473201', regexp: 'AT[0-9]{2}[0-9]{16}', test_regexp: 'AT'+TEST_IBAN },
      phone_number: '+43 123 4312123'
    },
    BE: {
      account_number: { title: 'IBAN', format: 'BE12345678912345', regexp: 'BE[0-9]{2}[0-9]{12}', test_regexp: 'BE'+TEST_IBAN },
      phone_number: '+32 123 03 21 72'
    },
    BR: {
      account_number: { format: 'format_varies_by_bank' },
      routing_1: { title: "bank_code", format: '123', regexp: '[0-9]{3}', test_regexp: '[0-9]{3}' },
      routing_2: { title: 'branch_code', regexp: '[0-9]{4,5}', test_regexp: '[0-9]{4,5}' },
      separator: "-"
    },
    CA: {
      account_number: { format: 'format_varies_by_bank' },
      routing_1: { title: 'transit_number', format: '12345', regexp: '[0-9]{5}', test_regexp: '[0-9]{5}'  },
      routing_2: { title: 'institution_number', format: '123', regexp: '[0-9]{3}', test_regexp: '[0-9]{3}' },
      separator: "-",
      phone_number: '+1 866 123 4567'
    },
    DK: {
      account_number: {title: 'IBAN', format: 'DK5000400440116243', regexp: 'DK[0-9]{2}[0-9]{14}', test_regexp: 'DK'+TEST_IBAN },
      phone_number: '+45 12 13 12 30'
    },
    EE: {
      account_number: {title: 'IBAN', format: 'EE382200221020145685', regexp: 'EE[0-9]{2}[0-9]{2}[0-9]{2}[0-9]{11}[0-9]{1}', test_regexp: 'EE'+TEST_IBAN },
      phone_number: '+372 000 1234'
    },
    FI: {
      account_number: {title: 'IBAN', format: 'FI2112345600000785', regexp: 'FI[0-9]{2}[0-9]{14}', test_regexp: 'FI'+TEST_IBAN },
      phone_number: '+358 45 1234123'
    },
    FR: {
      account_number: {title: 'IBAN', format: 'FR1420041010050500013M02606', regexp: 'FR[0-9]{2}[0-9]{10}[A-Z0-9]{11}[0-9]{2}', test_regexp: 'FR'+TEST_IBAN },
      phone_number: '+33 1 23 45 67 00'
    },
    DE: {
      account_number: {title: 'IBAN', format: 'DE89370400440532013000', regexp: 'DE[0-9]{2}[0-9]{18}', test_regexp: 'DE'+TEST_IBAN },
      phone_number: '+49 33 12373321'
    },
    GI: {
      account_number: { title: 'IBAN', format: 'GI75NWBK000000007099453', regexp: 'GI[0-9]{2}[A-Z]{4}[A-Z0-9]{15}', test_regexp: 'GI'+TEST_IBAN }
    },
    GR: {
      account_number: {title: 'IBAN', format: 'GR1601101250000000012300695', regexp: 'GR[0-9]{2}[0-9]{3}[0-9]{4}[A-Z0-9]{16}', test_regexp: 'GR'+TEST_IBAN },
      phone_number: '+30 21 1234 3300'
    },
    HK: {
      account_number: { format: '123456-789', regexp: '[0-9]{5,6}-[0-9]{1,3}', test_regexp: '[0-9]{5,6}-[0-9]{1,3}' },
      routing_1: { title: 'clearing_code', format: '123', regexp: '[0-9]{3}', test_regexp: '[0-9]{3}' },
      routing_2: { title: 'branch_code', format: '456', regexp: '[0-9]{3}', test_regexp: '[0-9]{3}' },
      separator: "-",
      phone_number: '+852 1234 5678'
    },
    IE: {
      account_number: {title: 'IBAN', format: 'IE29AIBK93115212345678', regexp: 'IE[0-9]{2}[A-Z0-9]{4}[0-9]{14}', test_regexp: 'IE'+TEST_IBAN },
      phone_number: '+353 1 234 5600'
    },
    IT: {
      account_number: {title: 'IBAN', format: 'IT60X0542811101000000123456', regexp: 'IT[0-9]{2}[A-Z]{1}[0-9]{5}[0-9]{5}[A-Z0-9]{12}', test_regexp: 'IT'+TEST_IBAN },
      phone_number: '+39 123 394512'
    },
    JP: {
      account_number: {format: '1234567', regexp: '[0-9]{6,8}', test_regexp: '[0-9]{6,8}' },
      routing_1: {title: "bank_code", format: '0123', regexp: '[0-9]{4}', test_regexp: '[0-9]{4}'},
      routing_2: {title: "branch_code", format: '456', regexp: '[0-9]{3}', test_regexp: '[0-9]{3}'},
      separator: "",
      phone_number: '+81 3 1234 2345'
    },
    LU: {
      account_number: {title: 'IBAN', format: 'LU280019400644750000', regexp: 'LU[0-9]{2}[0-9]{3}[A-Z0-9]{13}', test_regexp: 'LU'+TEST_IBAN },
      phone_number: '+352 45 12 34 0'
    },
    LT: {
      account_number: {title: 'IBAN', format: 'LT121000011101001000', regexp: 'LT[0-9]{2}[0-9]{5}[0-9]{11}', test_regexp: 'LT'+TEST_IBAN },
      phone_number: '+370 123 64 123'
    },
    LV: {
      account_number: {title: 'IBAN', format: 'LV80BANK0000435195001', regexp: 'LV[0-9]{2}[A-Z]{4}[A-Z0-9]{13}', test_regexp: 'LV'+TEST_IBAN },
      phone_number: '+371 12 123 450'
    },
    MX: {
      account_number: {title: 'CLABE', format: '123456789012345678', regexp: '[0-9]{18}', test_regexp: '[0-9]{18}' },
      phone_number: '+52 55 1234 5678'
    },
    NL: {
      account_number: {title: 'IBAN', format: 'NL39RABO0300065264', regexp: 'NL[0-9]{2}[A-Z]{4}[0-9]{10}', test_regexp: 'NL'+TEST_IBAN },
      phone_number: '+31 12 345 6705'
    },
    NZ: {
      account_number: {format: '11-0000-0000000-010', regexp: '[0-9]{2}\-[0-9]{4}\-[0-9]{7}\-[0-9]{2,3}', test_regexp: '[0-9]{2}\-[0-9]{4}\-[0-9]{7}\-[0-9]{2,3}' },
      phone_number: '+64 1 123 1200'
    },
    NO: {
      account_number: {title: 'IBAN', format: 'NO9386011117947', regexp: 'NO[0-9]{2}[0-9]{11}', test_regexp: 'NO'+TEST_IBAN },
      phone_number: '+47 21 12 34 56'
    },
    PL: {
      account_number: {title: 'IBAN', format: 'PL61109010140000071219812874', regexp: 'PL[0-9]{2}[0-9]{8}[0-9]{16}', test_regexp: 'PL'+TEST_IBAN },
      phone_number: '+48 12 345 78 09'
    },
    PT: {
      account_number: {title: 'IBAN', format: 'PT50123443211234567890172', regexp: 'PT[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{11}[0-9]{2}', test_regexp: 'PT'+TEST_IBAN },
      phone_number: '+351 12 345 7698'
    },
    SG: {
      account_number: {format: '123456789012', regexp: '[0-9]{6,12}', test_regexp: '[0-9]{6,12}' },
      routing_1: {title: "bank_code", format: '1234', regexp: '[0-9]{4}', test_regexp: '[0-9]{4}' },
      routing_2: {title: 'branch_code', format: '567', regexp: '[0-9]{3}', test_regexp: '[0-9]{3}'},
      separator: "-",
      phone_number: '+65 1234 5678'
    },
    SI: {
      account_number: {title: 'IBAN', format: 'SI56263300012039086', regexp: 'SI[0-9]{2}[0-9]{5}[0-9]{8}[0-9]{2}', test_regexp: 'SI'+TEST_IBAN },
      phone_number: '+386 1 234 12 34'
    },
    SK: {
      account_number: {title: 'IBAN', format: 'SK3112000000198742637541', regexp: 'SK[0-9]{2}[0-9]{4}[0-9]{6}[0-9]{10}', test_regexp: 'SK'+TEST_IBAN },
      phone_number: '+421 987 654 321'
    },
    ES: {
      account_number: {title: 'IBAN', format: 'ES9121000418450200051332', regexp: 'ES[0-9]{2}[0-9]{20}', test_regexp: 'ES'+TEST_IBAN },
      phone_number: '+34 123 12 34 21'
    },
    SE: {
      account_number: {title: 'IBAN', format: 'SE3550000000054910000003', regexp: 'SE[0-9]{2}[0-9]{20}', test_regexp: 'SE'+TEST_IBAN },
      phone_number: '+46 8 123 00 00'
    },
    CH: {
      account_number: {title: 'IBAN', format: 'CH9300762011623852957', regexp: 'CH[0-9]{2}[0-9]{5}[A-Z0-9]{12}', test_regexp: 'CH'+TEST_IBAN },
      phone_number: '+41 12 345 96 89'
    },
    GB: {
      account_number: {format: '01234567', regexp: '[0-9]{8}', test_regexp: '[0-9]{8}' },
      routing_number: {title: 'sort_code', format: '12-34-56', regexp: '[0-9]{2}-[0-9]{2}-[0-9]{2}', test_regexp: '108800' },
      phone_number: '+44 16 3296 0365'
    },
    US: {
      account_number: {format: 'format_varies_by_bank' },
      routing_number: {title: 'routing_number', format: '111000000', regexp: '[0-9]{9}', test_regexp: '[0-9]{9}' },
      phone_number: '+1 202 555 0191'
    },
    PR: {
      account_number: {format: 'format_varies_by_bank' },
      routing_number: {title: 'routing_number', format: '111000000', regexp: '[0-9]{9}', test_regexp: '[0-9]{9}' },
      phone_number: '+1 787 555 1234'
    }
  }.freeze


  def stripe_default_data2
    payment_settings = PaymentSettings.where(community_id: @current_community.id,
                                             payment_gateway: :stripe,
                                             payment_process: :preauthorize).first
    {
      stripe_test_mode: !!StripeService::API::Api.wrapper.test_mode?(@current_community.id),
      api_publishable_key: payment_settings.try(:api_publishable_key),
      bank_rules: BANK_RULES,
      error_nofication: I18n.t('layouts.notifications.an_error_occurred_when_saving_your_information', message: '%{message}')
    }
  end
end
