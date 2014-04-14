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
