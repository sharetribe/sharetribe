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
    describe "#first_words" do
      it "returns fifteen first words" do
        StringUtils.first_words("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et")
          .should eql("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore")

        StringUtils.first_words("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt")
          .should eql("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt")
      end

      it "returns empty string on nil" do
        StringUtils.first_words(nil).should eql("")
      end
    end
  end
end
