require 'spec_helper'

describe HashUtils do

  it "#map_keys" do
    h = {
      "a" => "a",
      "b" => "b"
    }

    expect(HashUtils.map_keys(h) { |k| k.upcase }).to eq({"A" => "a", "B" => "b"})
  end

  it "#rename_keys" do
    expect(HashUtils.rename_keys({foo: :bar}, {foo: 1, doo: 2}))
      .to eq({bar: 1, doo: 2})
    expect(HashUtils.rename_keys({foo: :bar}, {goo: 1, doo: 2}))
      .to eq({goo: 1, doo: 2})
  end

  it "#symbolize_keys" do
    expect(HashUtils.symbolize_keys({"foo" => 1, :bar => 2}))
      .to eq({foo: 1, bar: 2})
  end
end
