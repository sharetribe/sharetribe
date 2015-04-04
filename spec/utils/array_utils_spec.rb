require 'spec_helper'

describe ArrayUtils do

  it "#zip_by" do
    cars = [
      {make: "ferrari", car_color: "red"},
      {make: "honda", car_color: "yellow"},
      {make: "tesla", car_color: "black"}
    ]

    fruits = [
      {fruit: "apple", color: "red"},
      {fruit: "lemon", color: "yellow"},
      {fruit: "orange", color: "orange"}
    ]

    expected = [
      [{make: "ferrari", car_color: "red"}, {fruit: "apple", color: "red"}],
      [{make: "honda", car_color: "yellow"}, {fruit: "lemon", color: "yellow"}]
    ]

    actual = ArrayUtils.zip_by(cars, fruits) { |car, fruit|
      car[:car_color] == fruit[:color]
    }

    expect(actual).to eq(expected)
  end

end
