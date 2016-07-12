require 'spec_helper'

describe ColorUtils do

  describe "#brightness" do
    it "takes hex color and percentage and returns a new color with altered brightness" do
      expect(ColorUtils.brightness("80E619", 80)).to eq("66B814")
    end
  end

  describe "#darken" do
    it "takes hex color and percentage and returns darkened color" do
      expect(ColorUtils.darken("80E619", 20)).to eq("4D8A0F")
    end
  end

end
