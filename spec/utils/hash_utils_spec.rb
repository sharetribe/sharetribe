require 'spec_helper'

describe HashUtils do

  describe "#compact" do
    it "returns hash without nils" do
      expect(HashUtils.compact(a: nil, b: 2)).to eq(b: 2)
    end

    it "does not mutate the original hash" do
      h = {a: nil, b: 2}
      expect(HashUtils.compact(h)).to eq(b: 2)
      expect(h).to eq(a: nil, b: 2)
    end
  end


  it "#map_keys" do
    h = {
      "a" => "a",
      "b" => "b"
    }

    expect(HashUtils.map_keys(h) { |k| k.upcase }).to eq({"A" => "a", "B" => "b"})
  end

  it "#map_values" do
    h = {
      "a" => "a",
      "b" => "b"
    }

    expect(HashUtils.map_values(h) { |v| v.upcase }).to eq({"a" => "A", "b" => "B"})
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

  it "#pluck" do
    data = [{name: "John", age: 15}, {name: "Joe"}]
    expect(HashUtils.pluck(data, :name, :age)).to eq(["John", 15, "Joe"])
  end

  it "#sub" do
    expect(HashUtils.sub({first: "First", last: "Last", age: 55}, :first, :age, :sex))
      .to eq({first: "First", age: 55})
  end

  it "#sub_eq" do
    expect(HashUtils.sub_eq({a: 1, b: 2, c: 3}, {a: 1, b: 2, c: 4}, :a, :b)).to eq(true)
    expect(HashUtils.sub_eq({a: 1, b: 2, c: 3}, {a: 3, b: 2, c: 4}, :a, :b)).to eq(false)
  end

  describe "#transpose" do
    let(:h) { {a: [1, 2, 3], b: [2, 3, 4], c: [2]} }

    it "transposes hash keys and values" do
      expect(HashUtils.transpose(h))
        .to eq(
              {
                1 => [:a],
                2 => [:a, :b, :c],
                3 => [:a, :b],
                4 => [:b]
              })
    end

    it "transposing twice results original hash" do
      expect(HashUtils.transpose(HashUtils.transpose(h))).to eq(h)
    end
  end

  describe "#flatten" do
    it "makes deep structure flat" do
      expect(HashUtils.flatten(
        { a: { aa: { aaa: 1 },
               bb: 2,
               cc: { ccc: 3 }
             }
        }
        )).to eq(
             {
              :"a.aa.aaa" => 1,
              :"a.bb" => 2,
              :"a.cc.ccc" => 3
             }
           )
    end

    it "throws if key is not symbol or if it contains a dot" do
      expect { HashUtils.flatten("string" => 1) }
        .to raise_error(ArgumentError, "Key must be a Symbol and must not contain dot (.). Was: 'string', (String)")

      expect { HashUtils.flatten(:"a.b" => 1) }
        .to raise_error(ArgumentError, "Key must be a Symbol and must not contain dot (.). Was: 'a.b', (Symbol)")
    end
  end
end
