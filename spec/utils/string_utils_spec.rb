describe StringUtils do
  describe "#trim_and_hide" do
    it "returns only the last two numbers, hides the rest" do
      StringUtils.trim_and_hide("123", 5).should eql("123")
      StringUtils.trim_and_hide("  123   ", 5).should eql("123")
      StringUtils.trim_and_hide("12345", 5).should eql("12345")
      StringUtils.trim_and_hide("012345", 5).should eql("*12345")
      StringUtils.trim_and_hide("1235136342373").should eql("***********73")
      StringUtils.trim_and_hide("1235136342373", 4).should eql("*********2373")
      StringUtils.trim_and_hide("1235-1261-312").should eql("***********12")
      StringUtils.trim_and_hide("wardhtigaronfjkva").should eql("***************va")
    end
  end
end
