module MccCodes
  MCC_CODES_FILE = Rails.root.join('config', 'mcc_codes.json')

  class << self
    def codes
      @codes ||= read_from_file
    end

    private

    def read_from_file
      result = {}
      if File.exist?(MCC_CODES_FILE)
        result = JSON.parse(File.read(MCC_CODES_FILE))
      end
      result
    end
  end
end

