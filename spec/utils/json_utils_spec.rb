require 'spec_helper'

describe JSONUtils do

  def expect_symbolized(hash)
    expect(JSONUtils.symbolize_keys(hash))
  end

  describe "#symbolize_keys" do
    it "symbolizes Hash keys" do
      expect_symbolized("a" => "a").to eq(a: "a")
    end

    it "symbolizes Hash keys in Array" do
      expect_symbolized(["a" => "a"]).to eq([a: "a"])
    end

    it "symbolizes deep Hash keys" do
      expect_symbolized(
        "a" => "a",
        "b" => {
          "c" => {
            "d" => "d"
          }
        })
        .to eq(
              a: "a",
              b: {
                c: {
                  d: "d"
                }
              })
    end

    it "symbolizes deep Array keys" do
      expect_symbolized(
        [
          {"a" => [{"b" => "b", "c" => "c"}, {"d" => "d"}],
           "e" => "e"
          }])
        .to eq(
              [
                {a: [{b: "b", c: "c"}, {d: "d"}],
                 e: "e"
                }
              ])
    end
  end
end
