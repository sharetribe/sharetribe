require 'spec_helper'

describe EntityUtils do
  it "#define_entity" do
    Person = EntityUtils.define_entity(:name, :age)

    expect(Person[{name: "Peter", age: 31, likes_icecream: true}])
      .to eq({name: "Peter", age: 31})
    expect(Person[{name: "Peter"}])
      .to eq({name: "Peter", age: nil})
  end

  it "#define_builder" do
    Person = EntityUtils.define_builder(
      [:type, const_value: :person],
      [:name, :string, :mandatory],
      [:age, :optional, :fixnum, default: 8],
      [:sex, one_of: [:m, :f]],
      [:favorite_even_number, validate_with: -> (v) { v.nil? || v.even? }],
      [:tag, :optional, transform_with: -> (v) { v.to_sym unless v.nil? }]
    )


    # Transforming

    expect(Person.call({name: "First Last", sex: :m}))
      .to eq({type: :person, name: "First Last", age: 8, sex: :m, favorite_even_number: nil, tag: nil})

    expect(Person.call({name: "First Last", sex: :m, age: 5}))
      .to eq({type: :person, name: "First Last", age: 5, sex: :m, favorite_even_number: nil, tag: nil})

    expect(Person.call({name: "First Last", sex: :m, age: 5, tag: "hippy"}))
      .to eq({type: :person, name: "First Last", age: 5, sex: :m, favorite_even_number: nil, tag: :hippy})

    expect(Person.call({name: "First Last", sex: :m, age: 5, favorite_even_number: 4}))
      .to eq({type: :person, name: "First Last", age: 5, sex: :m, favorite_even_number: 4, tag: nil})


    # Validating

    expect{Person.call({name: nil, sex: :m})}
        .to raise_error

    expect{Person.call({name: 12, sex: :m})}
        .to raise_error

    expect{Person.call({name: "First Last", sex: :in_between})}
        .to raise_error

    expect{Person.call({name: "First Last", sex: :f, age: "12"})}
        .to raise_error

    expect{Person.call({name: "First Last", sex: :f, favorite_even_number: 3})}
        .to raise_error
  end

  it "#define_builder :callabla validator" do
    Entity = EntityUtils.define_builder([:say_so, :callable])

    expect{Entity.call({say_so: -> () { "Yes, that's the way it is." }})}
      .to_not raise_error

    expect{Entity.call({say_so: nil})}
      .to_not raise_error

    expect{Entity.call({say_so: "It ain't so"})}
      .to raise_error
  end

  it "#define builder :enumerable validator" do
    Entity = EntityUtils.define_builder([:tags, :enumerable])

    expect{Entity.call({tags: [1, 2]})}
      .to_not raise_error

    expect{Entity.call({tags: nil})}
      .to_not raise_error

    expect{Entity.call({tags: 2})}
      .to raise_error
  end
end
