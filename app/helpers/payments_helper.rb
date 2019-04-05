module PaymentsHelper
  TEST_IBAN = '89370400440532013000'

  BANK_RULES = {
    AU: {
      account_number: { format: 'format_varies_by_bank', regexp: '[0-9]{6,10}', test_regexp: '[0-9]{6,10}'},
      routing_number: { title: 'bsb',  format: '123456', regexp: '[0-9]{6}', test_regexp: '[0-9]{6}'}
    },
    AT: {
      account_number: { title: 'IBAN', format: 'AT611904300235473201', regexp: 'AT[0-9]{2}[0-9]{16}', test_regexp: 'AT'+TEST_IBAN }
    },
    BE: {
      account_number: { title: 'IBAN', format: 'BE12345678912345', regexp: 'BE[0-9]{2}[0-9]{12}', test_regexp: 'BE'+TEST_IBAN }
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
      separator: "-"
    },
    DK: {
      account_number: {title: 'IBAN', format: 'DK5000400440116243', regexp: 'DK[0-9]{2}[0-9]{14}', test_regexp: 'DK'+TEST_IBAN }
    },
    FI: {
      account_number: {title: 'IBAN', format: 'FI2112345600000785', regexp: 'FI[0-9]{2}[0-9]{14}', test_regexp: 'FI'+TEST_IBAN }
    },
    FR: {
      account_number: {title: 'IBAN', format: 'FR1420041010050500013M02606', regexp: 'FR[0-9]{2}[0-9]{10}[A-Z0-9]{11}[0-9]{2}', test_regexp: 'FR'+TEST_IBAN }
    },
    DE: {
      account_number: {title: 'IBAN', format: 'DE89370400440532013000', regexp: 'DE[0-9]{2}[0-9]{18}', test_regexp: 'DE'+TEST_IBAN }
    },
    GI: {
      account_number: { title: 'IBAN', format: 'GI75NWBK000000007099453', regexp: 'GI[0-9]{2}[A-Z]{4}[A-Z0-9]{15}', test_regexp: 'GI'+TEST_IBAN }
    },
    HK: {
      account_number: { format: '123456-789', regexp: '[0-9]{5,6}-[0-9]{1,3}', test_regexp: '[0-9]{5,6}-[0-9]{1,3}' },
      routing_1: { title: 'clearing_code', format: '123', regexp: '[0-9]{3}', test_regexp: '[0-9]{3}' },
      routing_2: { title: 'branch_code', format: '456', regexp: '[0-9]{3}', test_regexp: '[0-9]{3}' },
      separator: "-"
    },
    IE: {
      account_number: {title: 'IBAN', format: 'IE29AIBK93115212345678', regexp: 'IE[0-9]{2}[A-Z0-9]{4}[0-9]{14}', test_regexp: 'IE'+TEST_IBAN },
    },
    IT: {
      account_number: {title: 'IBAN', format: 'IT60X0542811101000000123456', regexp: 'IT[0-9]{2}[A-Z]{1}[0-9]{5}[0-9]{5}[A-Z0-9]{12}', test_regexp: 'IT'+TEST_IBAN },
    },
    JP: {
      account_number: {format: '1234567', regexp: '[0-9]{6,8}', test_regexp: '[0-9]{6,8}' },
      routing_1: {title: "bank_code", format: '0123', regexp: '[0-9]{4}', test_regexp: '[0-9]{4}'},
      routing_2: {title: "branch_code", format: '456', regexp: '[0-9]{3}', test_regexp: '[0-9]{3}'},
      separator: ""
    },
    LU: {
      account_number: {title: 'IBAN', format: 'LU280019400644750000', regexp: 'LU[0-9]{2}[0-9]{3}[A-Z0-9]{13}', test_regexp: 'LU'+TEST_IBAN },
    },
    MX: {
      account_number: {title: 'CLABE', format: '123456789012345678', regexp: '[0-9]{18}', test_regexp: '[0-9]{18}' }
    },
    NL: {
      account_number: {title: 'IBAN', format: 'NL39RABO0300065264', regexp: 'NL[0-9]{2}[A-Z]{4}[0-9]{10}', test_regexp: 'NL'+TEST_IBAN }
    },
    NZ: {
      account_number: {format: '11-0000-0000000-010', regexp: '[0-9]{2}\-[0-9]{4}\-[0-9]{7}\-[0-9]{2,3}', test_regexp: '[0-9]{2}\-[0-9]{4}\-[0-9]{7}\-[0-9]{2,3}' },
    },
    NO: {
      account_number: {title: 'IBAN', format: 'NO9386011117947', regexp: 'NO[0-9]{2}[0-9]{11}', test_regexp: 'NO'+TEST_IBAN },
    },
    PT: {
      account_number: {title: 'IBAN', format: 'PT50123443211234567890172', regexp: 'PT[0-9]{2}[0-9]{4}[0-9]{4}[0-9]{11}[0-9]{2}', test_regexp: 'PT'+TEST_IBAN },
    },
    SG: {
      account_number: {format: '123456789012', regexp: '[0-9]{6-12}', test_regexp: '[0-9]{6-12}' },
      routing_1: {title: "bank_code", format: '1234', regexp: '[0-9]{4}', test_regexp: '[0-9]{4}' },
      routing_2: {title: 'branch_code', format: '567', regexp: '[0-9]{3}', test_regexp: '[0-9]{3}'},
      separator: "-"
    },
    ES: {
      account_number: {title: 'IBAN', format: 'ES9121000418450200051332', regexp: 'ES[0-9]{2}[0-9]{20}', test_regexp: 'ES'+TEST_IBAN }
    },
    SE: {
      account_number: {title: 'IBAN', format: 'SE3550000000054910000003', regexp: 'SE[0-9]{2}[0-9]{20}', test_regexp: 'SE'+TEST_IBAN }
    },
    CH: {
      account_number: {title: 'IBAN', format: 'CH9300762011623852957', regexp: 'CH[0-9]{2}[0-9]{5}[A-Z0-9]{12}', test_regexp: 'CH'+TEST_IBAN }
    },
    GB: {
      account_number: {format: '01234567', regexp: '[0-9]{8}', test_regexp: '[0-9]{8}' },
      routing_number: {title: 'sort_code', format: '12-34-56', regexp: '[0-9]{2}-[0-9]{2}-[0-9]{2}', test_regexp: '108800' }
    },
    US: {
      account_number: {format: 'format_varies_by_bank' },
      routing_number: {title: 'routing_number', format: '111000000', regexp: '[0-9]{9}', test_regexp: '[0-9]{9}' }
    },
    PR: {
      account_number: {format: 'format_varies_by_bank' },
      routing_number: {title: 'routing_number', format: '111000000', regexp: '[0-9]{9}', test_regexp: '[0-9]{9}' }
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
    }
  end

  def mcc_codes_options
    result = [['-- Most popular', '0000']]
    first_codes = [
      'Equipment Rental',
      'General Services',
      'Miscellaneous Specialty Retail',
      'Professional Services',
      'Used Merchandise and Secondhand Stores'
    ]
    result += MccCodes::CODES.select{|x| first_codes.include?(x[:decription])}.map{|x| [x[:decription], x[:mcc]]}
    result += [['-- All categories', '0000']]
    result += MccCodes::CODES.map{|x| [x[:decription], x[:mcc]]}
  end
end
