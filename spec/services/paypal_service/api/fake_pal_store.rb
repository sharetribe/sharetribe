module PaypalService
  module API
    class FakePalStore
      def namespace
        raise InterfaceMethodNotImplementedError.new
      end
    end
  end
end
