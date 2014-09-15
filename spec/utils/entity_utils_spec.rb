require 'spec_helper'

describe EntityUtils do
  it "#rename_keys" do
    expect(EntityUtils.rename_keys({foo: :bar}, {foo: 1, doo: 2}))
      .to eq({bar: 1, doo: 2})
    expect(EntityUtils.rename_keys({foo: :bar}, {goo: 1, doo: 2}))
      .to eq({goo: 1, doo: 2})
  end

  it "#hash_keys_to_symbols" do
    expect(EntityUtils.hash_keys_to_symbols({"foo" => 1, :bar => 2}))
      .to eq({foo: 1, bar: 2})
  end

  it "#define_entity" do
    Person = EntityUtils.define_entity(:name, :age)

    expect(Person[{name: "Peter", age: 31, likes_icecream: true}])
      .to eq({name: "Peter", age: 31})
    expect(Person[{name: "Peter"}])
      .to eq({name: "Peter", age: nil})
  end
end
