require 'spec_helper'

describe ArrayUtils do

  describe "#inner_join" do
    it "joins by block" do
      cars = [
        {make: "ferrari", car_color: "red"},
        {make: "honda", car_color: "yellow"},
        {make: "lamborghini", car_color: "yellow"},
        {make: "tesla", car_color: "black"}
      ]

      fruits = [
        {fruit: "apple", color: "red"},
        {fruit: "strawberry", color: "red"},
        {fruit: "lemon", color: "yellow"},
        {fruit: "orange", color: "orange"}
      ]

      expected = [
        [{make: "ferrari", car_color: "red"}, {fruit: "apple", color: "red"}, {fruit: "strawberry", color: "red"}],
        [{make: "honda", car_color: "yellow"}, {fruit: "lemon", color: "yellow"}],
        [{make: "lamborghini", car_color: "yellow"}, {fruit: "lemon", color: "yellow"}]
      ]

      actual = ArrayUtils.inner_join(cars, fruits) { |car, fruit|
        car[:car_color] == fruit[:color]
      }

      expect(actual).to eq(expected)

      # you can use array destruction to handle the result
      only_first = actual.map { |(car, fruit)| [car[:make], fruit[:fruit]] }
      expect(only_first).to eq([["ferrari", "apple"], ["honda", "lemon"], ["lamborghini", "lemon"]])

      all = actual.map { |(car, *fruits)| [car[:make], fruits.map { |fruit| fruit[:fruit] }] }

      expect(all).to eq([["ferrari", ["apple", "strawberry"]], ["honda", ["lemon"]], ["lamborghini", ["lemon"]]])
    end

    it "joins without block" do
      a = ["a", "b", "c", "c", "d"]
      b = ["a", "b", "b", "c", "e"]

      actual = ArrayUtils.inner_join(a, b)

      expected = [["a", "a"], ["b", "b", "b"], ["c", "c"], ["c", "c"]]

      expect(actual).to eq(expected)
    end
  end

  describe "#diff" do
    let(:xs) {
      [
        {id: 1, value: "a"},
        {id: 2, value: "b"},
        {id: 3, value: "c"}
      ]
    }

    it "shows added elements" do
      new = {value: "d"} # added items may not have ID

      from_begin = [new, xs[0], xs[1], xs[2]]
      from_mid = [xs[0], new, xs[1], xs[2]]
      from_end = [xs[0], xs[1], xs[2], new]

      [from_begin, from_mid, from_end].each { |changed|
        expect(ArrayUtils.diff_by_key(xs, changed, :id)).to eq([{action: :added, value: {value: "d"}}])
      }
    end

    it "shows removed elements" do
      from_begin = [xs[1], xs[2]]
      from_mid = [xs[0], xs[2]]
      from_end = [xs[0], xs[1]]

      expect(ArrayUtils.diff_by_key(xs, from_begin, :id)).to eq([{action: :removed, value: {id: 1, value: "a"}}])
      expect(ArrayUtils.diff_by_key(xs, from_mid, :id)).to eq([{action: :removed, value: {id: 2, value: "b"}}])
      expect(ArrayUtils.diff_by_key(xs, from_end, :id)).to eq([{action: :removed, value: {id: 3, value: "c"}}])
    end

    it "shows changed elements" do
      from_begin = [{id: 1, value: "A"}, xs[1], xs[2]]
      from_mid = [xs[0], {id: 2, value: "B"}, xs[2]]
      from_end = [xs[0], xs[1], {id: 3, value: "C"}]

      expect(ArrayUtils.diff_by_key(xs, from_begin, :id)).to eq([{action: :changed, value: {id: 1, value: "A"}}])
      expect(ArrayUtils.diff_by_key(xs, from_mid, :id)).to eq([{action: :changed, value: {id: 2, value: "B"}}])
      expect(ArrayUtils.diff_by_key(xs, from_end, :id)).to eq([{action: :changed, value: {id: 3, value: "C"}}])
    end

    it "returns empty array if no changes" do
      expect(ArrayUtils.diff_by_key(xs, xs, :id)).to eq([])
    end
  end

end
