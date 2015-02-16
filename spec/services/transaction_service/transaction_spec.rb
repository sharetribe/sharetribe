describe TransactionService::Transaction do
  TxService = TransactionService::Transaction

  context "#calculate_commission" do
    it "picks the largest of relative and fixed commission " do
      expect(TxService.calculate_commission(Money.new(1000, "USD"), 10, Money.new(50, "USD")))
        .to eql Money.new(100, "USD")
      expect(TxService.calculate_commission(Money.new(1000, "USD"), 10, Money.new(150, "USD")))
        .to eql Money.new(150, "USD")
    end

    it "handles nil percentage / min commission as zero" do
      expect(TxService.calculate_commission(Money.new(1000, "USD"), nil, Money.new(50, "USD")))
        .to eql Money.new(50, "USD")
      expect(TxService.calculate_commission(Money.new(1000, "USD"), 10, nil))
        .to eql Money.new(100, "USD")
      expect(TxService.calculate_commission(Money.new(1000, "USD"), nil, nil))
        .to eql Money.new(0, "USD")
    end
  end
end
