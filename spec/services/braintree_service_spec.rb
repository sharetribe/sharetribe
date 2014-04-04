describe BraintreeService do
  describe "#hide_account_number" do
    it "returns only the last two numbers, hides the rest" do
      BraintreeService.hide_account_number("123", 5).should eql("123")
      BraintreeService.hide_account_number("  123   ", 5).should eql("123")
      BraintreeService.hide_account_number("12345", 5).should eql("12345")
      BraintreeService.hide_account_number("012345", 5).should eql("*12345")
      BraintreeService.hide_account_number("1235136342373").should eql("***********73")
      BraintreeService.hide_account_number("1235136342373", 4).should eql("*********2373")
      BraintreeService.hide_account_number("1235-1261-312").should eql("***********12")
      BraintreeService.hide_account_number("wardhtigaronfjkva").should eql("***************va")
    end
  end

  describe "#release_from_escrow" do
    let(:transaction_mock) { Struct.new(:escrow_status) }
    let(:community) { FactoryGirl.create(:community) }

    context 'when escrow status is "held"' do
      before do
        BraintreeApi.stub(:find_transaction) { transaction_mock.new("held") }
      end

      it 'releases immediately from escrow' do
        BraintreeApi.should_receive(:release_from_escrow)
        BraintreeService.release_from_escrow(community, "123")
      end
    end

    context 'when escrow status changed from "hold_pending" to "held"' do

      it 'releases from escrow later' do
        @api_calls = 0
        BraintreeApi.stub(:release_from_escrow) do
          @api_calls += 1
        end

        before_batch = Time.new(2014, 3, 11, 20, 0, 0, 0)
        Timecop.freeze(before_batch)

        # Hold pending
        BraintreeApi.stub(:find_transaction) { transaction_mock.new("hold_pending") }
        BraintreeService.release_from_escrow(community, "123")
        @api_calls.should == 0

        # Time passes 24, but still hold bending
        Timecop.freeze(24.hours.from_now)
        successes, failures = Delayed::Worker.new.work_off
        successes.should == 1
        failures.should == 0
        @api_calls.should == 0

        # Time passes another 24, status changed to "held"
        Timecop.freeze(24.hours.from_now)
        BraintreeApi.stub(:find_transaction) { transaction_mock.new("held") }
        successes, failures = Delayed::Worker.new.work_off
        successes.should == 1
        failures.should == 0
        @api_calls.should == 1
      end
    end
  end

  describe "#next_escrow_release_time" do
    context 'when todays batch has not been run yet' do
      it 'returns time of todays batch and buffer' do
        next_batch = BraintreeService.next_escrow_release_time(Time.new(2014, 3, 11, 22, 0, 0, 0), 2)
        next_batch.utc.should be_eql(Time.new(2014, 3, 12, 1, 0, 0, 0))
      end
    end

    context 'when todays batch has been run already' do
      it 'returns time of tomorrows batch and buffer' do
        next_batch = BraintreeService.next_escrow_release_time(Time.new(2014, 3, 11, 23, 10, 0, 0), 2)
        next_batch.utc.should be_eql(Time.new(2014, 3, 13, 1, 0, 0, 0))
      end
    end
  end
end
