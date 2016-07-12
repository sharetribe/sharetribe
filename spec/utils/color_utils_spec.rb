require 'spec_helper'

describe ColorUtils do

  describe "#brightness" do
    it "takes hex color and percentage and returns a new color with altered brightness" do
      expect(ColorUtils.brightness("80E619", 80)).to eq("66B814")
    end
  end
end
