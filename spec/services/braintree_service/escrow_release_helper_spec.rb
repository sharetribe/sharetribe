describe BraintreeService::EscrowReleaseHelper do

  describe "#release_from_escrow" do
    let(:transaction_mock) { Struct.new(:escrow_status) }
    let(:community) { FactoryGirl.create(:community) }

    context 'when escrow status is "held"' do
      before do
        allow(BraintreeApi).to receive(:find_transaction) { transaction_mock.new("held") }
      end

      it 'releases immediately from escrow' do
        expect(BraintreeApi).to receive(:release_from_escrow)
        BraintreeService::EscrowReleaseHelper.release_from_escrow(community, "123")
      end
    end

    context 'when escrow status changed from "hold_pending" to "held"' do

      it 'releases from escrow later' do
        @api_calls = 0
        allow(BraintreeApi).to receive(:release_from_escrow) do
          @api_calls += 1
        end

        before_batch = Time.new(2014, 3, 11, 20, 0, 0, 0)

        Timecop.freeze(before_batch) {
          # Hold pending
          allow(BraintreeApi).to receive(:find_transaction) { transaction_mock.new("hold_pending") }
          BraintreeService::EscrowReleaseHelper.release_from_escrow(community, "123")
          expect(@api_calls).to eq(0)
        }

        # Time passes 24, but still hold bending
        Timecop.freeze(24.hours.since(before_batch)) {
          successes, failures = Delayed::Worker.new.work_off
          expect(successes).to eq(1)
          expect(failures).to eq(0)
          expect(@api_calls).to eq(0)
        }

        # Time passes another 24, status changed to "held"
        Timecop.freeze(48.hours.since(before_batch)) {
          allow(BraintreeApi).to receive(:find_transaction) { transaction_mock.new("held") }
          successes, failures = Delayed::Worker.new.work_off
          expect(successes).to eq(1)
          expect(failures).to eq(0)
          expect(@api_calls).to eq(1)
        }
      end
    end
  end

  describe "#next_escrow_release_time" do

    def central_time(*args)
      ActiveSupport::TimeZone.new("Central Time (US & Canada)").local(*args)
    end

    context 'when todays batch has not been run yet' do
      it 'returns time of todays batch and buffer' do
        next_batch = BraintreeService::EscrowReleaseHelper.next_escrow_release_time(Time.new(2014, 3, 11, 21, 0, 0, 0), 2)
        expect(next_batch).to be_eql(central_time(2014, 3, 11, 19, 0, 0))
      end
    end

    context 'when todays batch has been run already' do
      it 'returns time of tomorrows batch and buffer' do
        next_batch = BraintreeService::EscrowReleaseHelper.next_escrow_release_time(Time.new(2014, 3, 11, 23, 10, 0, 0), 2)
        expect(next_batch).to be_eql(central_time(2014, 3, 12, 19, 0, 0))
      end
    end
  end
end
