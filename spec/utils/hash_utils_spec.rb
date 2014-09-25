require 'spec_helper'

describe HashUtils do

  it "#map_keys" do
    h = {
      "a" => "a",
      "b" => "b"
    }

    expect(HashUtils.map_keys(h) { |k| k.upcase }).to eq({"A" => "a", "B" => "b"})
  end

  it "#symbolize_keys" do
    h = {
      "a" => "a",
      "b" => "b"
    }

    expect(HashUtils.symbolize_keys(h) { |k| k.upcase }).to eq({a: "a", b: "b"})
  end
end
