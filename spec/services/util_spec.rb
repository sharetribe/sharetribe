describe Util::MoneyUtil do
  it "#parse_money_to_cents" do
    Util::MoneyUtil.parse_money_to_cents("100").should eql(10000)
    Util::MoneyUtil.parse_money_to_cents("100.00").should eql(10000)
    Util::MoneyUtil.parse_money_to_cents("100,00").should eql(10000)
    Util::MoneyUtil.parse_money_to_cents("99,99").should eql(9999)
    Util::MoneyUtil.parse_money_to_cents("99.99").should eql(9999)
    Util::MoneyUtil.parse_money_to_cents("0.12").should eql(12)
    Util::MoneyUtil.parse_money_to_cents("0,12").should eql(12)
  end
end

describe Util::HashUtils do
  it "#camelize_keys" do
    expected = {
      outerKey1: {
        innerKey1: {
          innerInnerKey1: "foo",
          innerInnerKey2: "bar"
        },
        innerKey2: "foo",
        innerKey3: "bar"
      },
      outerKey2: "foo"
    }

    test_data = {
      outer_key_1: {
        inner_key_1: {
          inner_inner_key_1: "foo",
          inner_inner_key_2: "bar"
        },
        inner_key_2: "foo",
        inner_key_3: "bar"
      },
      outer_key_2: "foo"
    }

    Util::HashUtils.camelize_keys(test_data).should eql(expected)
  end

  it "#deep_map" do
    test_data = {
      foo: {
        bar: {
          one: 1,
          two: 2
        },
        three: 3
      },
      four: 4
    }

    expected = {
      foo: {
        bar: {
          one: 1,
          two: 4
        },
        three: 9
      },
      four: 16
    }

    actual = Util::HashUtils.deep_map(test_data) { |k, v| v * v }

    actual.should eql(expected)
  end

  it "#select_by_key_regexp" do
    h = { :first_key => 1, :second_key => 2, :first_first_key => 11 }
    Util::HashUtils.select_by_key_regexp(h, /^first_/).should eql({ :first_key => 1, :first_first_key => 11 })
  end

  it "#deep_contains" do
    Util::HashUtils.deep_contains({a: 1}, {a: 1, b: 2}).should be_true
    Util::HashUtils.deep_contains({a: 2}, {a: 1, b: 2}).should be_false
    Util::HashUtils.deep_contains({a: 1, b: 1}, {a: 1, b: 2}).should be_false
    Util::HashUtils.deep_contains({a: 1, b: 2}, {a: 1, b: 2}).should be_true
    Util::HashUtils.deep_contains({c: 3}, {a: 1, b: 2}).should be_false
  end
end

describe Util::StringUtils do
  it "#first_words" do
    Util::StringUtils.first_words("Take the first five words of this sentence.", 5).should eql "Take the first five words"
  end

  it "#strip_punctuation" do
    Util::StringUtils.strip_punctuation("yes!").should eql "yes"
  end

  it "#strip_small_words" do
    Util::StringUtils.strip_small_words("this is a test", 0).should eql "this is a test"
    Util::StringUtils.strip_small_words("this is a test", 1).should eql "this is test"
    Util::StringUtils.strip_small_words("this is a test", 2).should eql "this test"
    Util::StringUtils.strip_small_words("this is a test", 4).should eql ""
    Util::StringUtils.strip_small_words("the best thing it is!", 2).should eql "the best thing"
  end

  it "#keywords" do
    Util::StringUtils.keywords("This marketplace is a place! where I can sell and buy stuff", 5).should eql "this, marketplace, place, where, can"
  end
end

describe Util::ArrayUtils do
  include Util::ArrayUtils

  it "#each_slice_columns" do
    each_slice_columns([1], 3).to_a.should eql([[1]])
    each_slice_columns([1, 2], 3).to_a.should eql([[1], [2]])
    each_slice_columns([1, 2, 3], 3).to_a.should eql([[1], [2], [3]])
    each_slice_columns([1, 2, 3, 4], 3).to_a.should eql([[1, 2], [3], [4]])
    each_slice_columns([1, 2, 3, 4, 5], 3).to_a.should eql([[1, 2], [3, 4], [5]])
    each_slice_columns([1, 2, 3, 4, 5, 6], 3).to_a.should eql([[1, 2], [3, 4], [5, 6]])
    each_slice_columns([1, 2, 3, 4, 5, 6, 7], 3).to_a.should eql([[1, 2, 3], [4, 5], [6, 7]])
  end

  it "#trim" do
    trim([1, 2, 3]).should eql([1, 2, 3])

    # Trim from begining
    trim([nil, 1, 2, 3]).should eql([1, 2, 3])
    trim([nil, nil, 1, 2, 3]).should eql([1, 2, 3])

    # Trim from end
    trim([1, 2, 3, nil]).should eql([1, 2, 3])
    trim([1, 2, 3, nil, nil]).should eql([1, 2, 3])

    # Trim from both
    trim([nil, 1, 2, 3, nil]).should eql([1, 2, 3])
    trim([nil, nil, 1, 2, 3, nil, nil]).should eql([1, 2, 3])

    # Don't trim from the middle
    trim([1, nil, 2, nil, 3]).should eql([1, nil, 2, nil, 3])
    trim([nil, 1, nil, 2, nil, 3, nil]).should eql([1, nil, 2, nil, 3])
  end
end
