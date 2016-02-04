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

    expect(HashUtils.camelize_keys(test_data)).to eql(expected)
  end

  it "#select_by_key_regexp" do
    h = { :first_key => 1, :second_key => 2, :first_first_key => 11 }
    expect(HashUtils.select_by_key_regexp(h, /^first_/)).to eql({ :first_key => 1, :first_first_key => 11 })
  end

  it "#deep_contains" do
    expect(HashUtils.deep_contains({a: 1}, {a: 1, b: 2})).to be_truthy
    expect(HashUtils.deep_contains({a: 2}, {a: 1, b: 2})).to be_falsey
    expect(HashUtils.deep_contains({a: 1, b: 1}, {a: 1, b: 2})).to be_falsey
    expect(HashUtils.deep_contains({a: 1, b: 2}, {a: 1, b: 2})).to be_truthy
    expect(HashUtils.deep_contains({c: 3}, {a: 1, b: 2})).to be_falsey
  end
end

describe StringUtils do
  it "#first_words" do
    expect(StringUtils.first_words("Take the first five words of this sentence.", 5)).to eql "Take the first five words"
  end

  it "#strip_punctuation" do
    expect(StringUtils.strip_punctuation("yes!")).to eql "yes"
  end

  it "#strip_small_words" do
    expect(StringUtils.strip_small_words("this is a test", 0)).to eql "this is a test"
    expect(StringUtils.strip_small_words("this is a test", 1)).to eql "this is test"
    expect(StringUtils.strip_small_words("this is a test", 2)).to eql "this test"
    expect(StringUtils.strip_small_words("this is a test", 4)).to eql ""
    expect(StringUtils.strip_small_words("the best thing it is!", 2)).to eql "the best thing"
  end

  it "#keywords" do
    expect(StringUtils.keywords("This marketplace is a place! where I can sell and buy stuff", 5)).to eql "this, marketplace, place, where, sell"
  end
end

describe ArrayUtils do
  include ArrayUtils

  it "#each_slice_columns" do
    expect(each_slice_columns([1], 3).to_a).to eql([[1]])
    expect(each_slice_columns([1, 2], 3).to_a).to eql([[1], [2]])
    expect(each_slice_columns([1, 2, 3], 3).to_a).to eql([[1], [2], [3]])
    expect(each_slice_columns([1, 2, 3, 4], 3).to_a).to eql([[1, 2], [3], [4]])
    expect(each_slice_columns([1, 2, 3, 4, 5], 3).to_a).to eql([[1, 2], [3, 4], [5]])
    expect(each_slice_columns([1, 2, 3, 4, 5, 6], 3).to_a).to eql([[1, 2], [3, 4], [5, 6]])
    expect(each_slice_columns([1, 2, 3, 4, 5, 6, 7], 3).to_a).to eql([[1, 2, 3], [4, 5], [6, 7]])
  end

  it "#trim" do
    expect(trim([1, 2, 3])).to eql([1, 2, 3])

    # Trim from begining
    expect(trim([nil, 1, 2, 3])).to eql([1, 2, 3])
    expect(trim([nil, nil, 1, 2, 3])).to eql([1, 2, 3])

    # Trim from end
    expect(trim([1, 2, 3, nil])).to eql([1, 2, 3])
    expect(trim([1, 2, 3, nil, nil])).to eql([1, 2, 3])

    # Trim from both
    expect(trim([nil, 1, 2, 3, nil])).to eql([1, 2, 3])
    expect(trim([nil, nil, 1, 2, 3, nil, nil])).to eql([1, 2, 3])

    # Don't trim from the middle
    expect(trim([1, nil, 2, nil, 3])).to eql([1, nil, 2, nil, 3])
    expect(trim([nil, 1, nil, 2, nil, 3, nil])).to eql([1, nil, 2, nil, 3])
  end
end
