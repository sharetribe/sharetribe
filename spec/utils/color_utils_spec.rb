require 'spec_helper'

describe ColorUtils do

  describe "#brightness" do
    it "takes hex color and percentage and returns a new color with altered brightness" do
      expect(ColorUtils.brightness("80E619", 80)).to eq("66B814")
      expect(ColorUtils.brightness("80E619", 90)).to eq("73CF17")
      expect(ColorUtils.brightness("80E619", 110)).to eq("8DFD1C")
      expect(ColorUtils.brightness("80E619", 300)).to eq("FFFF4B")
    end
  end
end
