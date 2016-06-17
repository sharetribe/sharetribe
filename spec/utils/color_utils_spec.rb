require 'spec_helper'

describe ColorUtils do

  describe "#darken" do
    it "takes hex color and percentage and returns darkened color" do
      expect(ColorUtils.darken("80E619", 20)).to eq("4D8A0F")
    end
  end

end
