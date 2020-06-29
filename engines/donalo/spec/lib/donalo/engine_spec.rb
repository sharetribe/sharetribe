require "rails_helper"

describe Donalo::Engine::SendPaymentReceiptsOverride do
  describe '#seller_should_receive_receipt' do
    class DummyReceiver
      include Donalo::Engine::SendPaymentReceiptsOverride
    end

    it 'returns false' do
      dummy_receiver = DummyReceiver.new
      result = dummy_receiver.seller_should_receive_receipt(nil)
      expect(result).to eq(false)
    end
  end
end
