describe HashUtils do
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

    HashUtils.camelize_keys(test_data).should eql(expected)
  end

  it "#select_by_key_regexp" do
    h = { :first_key => 1, :second_key => 2, :first_first_key => 11 }
    HashUtils.select_by_key_regexp(h, /^first_/).should eql({ :first_key => 1, :first_first_key => 11 })
  end

  it "#deep_contains" do
    HashUtils.deep_contains({a: 1}, {a: 1, b: 2}).should be_truthy
    HashUtils.deep_contains({a: 2}, {a: 1, b: 2}).should be_falsey
    HashUtils.deep_contains({a: 1, b: 1}, {a: 1, b: 2}).should be_falsey
    HashUtils.deep_contains({a: 1, b: 2}, {a: 1, b: 2}).should be_truthy
    HashUtils.deep_contains({c: 3}, {a: 1, b: 2}).should be_falsey
  end
end

describe StringUtils do
  it "#first_words" do
    StringUtils.first_words("Take the first five words of this sentence.", 5).should eql "Take the first five words"
  end

  it "#strip_punctuation" do
    StringUtils.strip_punctuation("yes!").should eql "yes"
  end

  it "#strip_small_words" do
    StringUtils.strip_small_words("this is a test", 0).should eql "this is a test"
    StringUtils.strip_small_words("this is a test", 1).should eql "this is test"
    StringUtils.strip_small_words("this is a test", 2).should eql "this test"
    StringUtils.strip_small_words("this is a test", 4).should eql ""
    StringUtils.strip_small_words("the best thing it is!", 2).should eql "the best thing"
  end

  it "#keywords" do
    StringUtils.keywords("This marketplace is a place! where I can sell and buy stuff", 5).should eql "this, marketplace, place, where, sell"
  end
end

describe ArrayUtils do
  include ArrayUtils

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
