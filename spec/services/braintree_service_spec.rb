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
    let(:community) { Struct.new(:id).new(0) }

    context 'when escrow status is "held"' do
      before do
        BraintreeApi.stub(:find_transaction) { transaction_mock.new("held") }
      end

      it 'releases immediately from escrow' do
        BraintreeApi.should_receive(:release_from_escrow)
        BraintreeService.release_from_escrow(community, "123")
      end
    end

    context 'when escrow status is "hold_pending"' do
      before do
        BraintreeApi.stub(:find_transaction) { transaction_mock.new("hold_pending") }
      end

      it 'releases after next settlement batch' do
        BraintreeService.should_receive(:release_from_escrow_after_next_batch)
        BraintreeService.release_from_escrow(community, "123")
      end
    end

    context 'when there\' release job in queue and escrow status has changed to "held"' do
      before do
        BraintreeService.release_from_escrow_after_next_batch(community.id, "123")
        BraintreeApi.stub(:find_transaction) { transaction_mock.new("held") }
      end

      it 'should run the job' do
        BraintreeApi.should_receive(:release_from_escrow)
        Timecop.travel(15.hours.from_now)
        successes, failures = Delayed::Worker.new.work_off
        successes.should == 1
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