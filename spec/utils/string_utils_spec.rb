describe StringUtils do
  describe "#trim_and_hide" do
    it "returns only the last two numbers, hides the rest" do
      expect(StringUtils.trim_and_hide("123", 5)).to eql("123")
      expect(StringUtils.trim_and_hide("  123   ", 5)).to eql("123")
      expect(StringUtils.trim_and_hide("12345", 5)).to eql("12345")
      expect(StringUtils.trim_and_hide("012345", 5)).to eql("*12345")
      expect(StringUtils.trim_and_hide("1235136342373")).to eql("***********73")
      expect(StringUtils.trim_and_hide("1235136342373", 4)).to eql("*********2373")
      expect(StringUtils.trim_and_hide("1235-1261-312")).to eql("***********12")
      expect(StringUtils.trim_and_hide("wardhtigaronfjkva")).to eql("***************va")
    end
    describe "#first_words" do
      it "returns fifteen first words" do
        expect(StringUtils.first_words("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et"))
          .to eql("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore")

        expect(StringUtils.first_words("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt"))
          .to eql("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt")
      end

      it "returns empty string on nil" do
        expect(StringUtils.first_words(nil)).to eql("")
      end
    end
  end
end
