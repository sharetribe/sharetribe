module MarketplaceService
  module Result

    Success = Struct.new(
      :success, # Boolean
      :data # Additional response data
    ) do

      def initialize(data = nil)
        self.success = true
        self.data = data
      end
    end

    Error = Struct.new(
        :success,
        :error_msg
      ) do

      def initialize(error_msg)
        self.success = false
        self.error_msg = error_msg
      end
    end

  end
end
