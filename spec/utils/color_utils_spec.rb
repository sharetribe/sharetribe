require 'spec_helper'

describe ColorUtils do

  describe "#brightness" do
    it "takes hex color and percentage and returns a new color with altered brightness" do
      expect(ColorUtils.brightness("80E619", 80)).to eq("66B814")
      expect(ColorUtils.brightness("80E619", 90)).to eq("73CF17")
      expect(ColorUtils.brightness("80E619", 110)).to eq("8DFD1C")
      expect(ColorUtils.brightness("80E619", 300)).to eq("FFFF4B")
    end

    it "works with predefined frozen colors" do
      # FF00FF is a official Pink color, thus it's frozen by the Color gemfile
      expect(ColorUtils.brightness("FF00FF", 80)).to eq("CC00CC")
    end
  end
end
