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
end