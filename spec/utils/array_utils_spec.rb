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

end
