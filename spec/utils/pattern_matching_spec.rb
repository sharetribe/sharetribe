describe "pattern matching" do

  def test(value, pattern)
    case value
    when matches(pattern)
      true
    else
      false
    end
  end

  it "matches values" do
    expect(test([true], [true])).to eql(true)
    expect(test([false], [true])).to eql(false)
    expect(test([true], [false])).to eql(false)

    expect(test([1, 2, 3], [1, 2, 3])).to eql(true)
    expect(test([1, 1, 1], [1, 2, 3])).to eql(false)
  end

  it "matches wildcard" do
    expect(test([true], [__])).to eql(true)
    expect(test([false], [__])).to eql(true)
  end

  it "ignores rest, if the are not in pattern array" do
    expect(test([1, 2], [])).to eql(true)
    expect(test([1, 2], [1])).to eql(true)
    expect(test([1, 2], [2])).to eql(false)
    expect(test([1, 2], [1, 2])).to eql(true)
    expect(test([1, 2], [1, 2, 3])).to eql(false)
  end

  it "knows how to use more sophisticated patterns" do
    expect(test([1, 2], [Integer, Hash])).to eql(false)
    expect(test([1, 2], [Integer, Integer])).to eql(true)

    expect(test([1, 2], [Integer, (4..10)])).to eql(false)
    expect(test([1, 2], [Integer, (1..3)])).to eql(true)

    expect(test([1, [2, 3]], [Integer, [1, 3]])).to eql(false)
    expect(test([1, [2, 3]], [Integer, [2, 3]])).to eql(true)

    # Improvement ideas!
    expect(test([1, [2, 3]], [Integer, [Integer, (1..3)]])).to eql(false) # Does not match nested arrays. Should it? Maybe!
    expect(test([1, {a: 1, b: 2}], [Integer, Hash])).to eql(true)
    expect(test([1, {a: 1, b: 2}], [Integer, {a: 1, b: 2}])).to eql(true)
    expect(test([1, {a: 1, b: 2}], [Integer, {a: Integer, b: (1..3)}])).to eql(false) # Does not use Hashes as patterns. Should it? Maybe!
  end
end
