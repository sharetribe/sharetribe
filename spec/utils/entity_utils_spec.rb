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
      [:favorite_even_number, validate_with: -> (v) {
         unless v.nil? || v.even?
           {code: :even, msg: "Value must be a even number. Was: #{v}"}
         end
       }],
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

  it "#define_builder supports nested entities" do
    Entity = EntityUtils.define_builder(
      [:name, :mandatory, entity: [
         [:first, :string, :mandatory],
         [:middle, :string, default: "Middle"],
         [:last, :string, :mandatory]
       ]])

    # Validators
    expect{Entity.call({name: {first: 'First', last: 'Last'}})}
      .not_to raise_error

    expect{Entity.call({name: {first: 'First', middle: 'Middle'}})}
      .to raise_error

    # Transformers
    expect(Entity.call({name: {first: 'First', last: 'Last'}})).to eq({name: {first: 'First', middle: 'Middle', last: 'Last'}})

  end

  it "#define_builder can nest other builders" do
    NameDetails = EntityUtils.define_builder(
      [:first, :string, :mandatory],
      [:middle, :string, default: "Middle"],
      [:last, :string, :mandatory]
    )

    Entity = EntityUtils.define_builder(
      [:name, :mandatory, entity: NameDetails]
    )

    # Validators
    expect{Entity.call({name: {first: 'First', last: 'Last'}})}
      .not_to raise_error

    expect{Entity.call({name: {first: 'First', middle: 'Middle'}})}
      .to raise_error
  end

  it "#define_builder supports nested entity collections" do
    Entity = EntityUtils.define_builder(
      [:name, :mandatory, collection: [
         [:type, :mandatory, one_of: [:first, :middle, :last]],
         [:value, :mandatory, :string],
         [:calling_name, default: false]
       ]])

    # Validators
    expect{Entity.call({name: [{type: :first, value: 'First'}, {type: :last, value: 'Last'}]})}
      .not_to raise_error

    expect{Entity.call({name: [{type: :first, value: 'First'}, {type: :second_middle, value: 'Second Middle'}]})}
      .to raise_error

    # Transformers
    expect(Entity.call({name: [{type: :first, value: 'First', calling_name: true}, {type: :last, value: 'Last'}]}))
      .to eq({name: [{type: :first, value: 'First', calling_name: true}, {type: :last, value: 'Last', calling_name: false}]})

  end

  it "#define_builder can nest other builders for collections" do
    NameDetails = EntityUtils.define_builder(
      [:type, :mandatory, one_of: [:first, :middle, :last]],
      [:value, :mandatory, :string],
      [:calling_name, default: false]
    )

    Entity = EntityUtils.define_builder(
      [:name, :mandatory, collection: NameDetails])

    # Validators
    expect{Entity.call({name: [{type: :first, value: 'First'}, {type: :last, value: 'Last'}]})}
      .not_to raise_error

    expect{Entity.call({name: [{type: :first, value: 'First'}, {type: :second_middle, value: 'Second Middle'}]})}
      .to raise_error

  end

  it "#define_builder returns error field path message for nested entities" do
    Entity = EntityUtils.define_builder(
      [:name, :mandatory, entity: [
         [:first, :string, :mandatory],
         [:middle, :string, default: "Middle"],
         [:last, :string, :mandatory]
       ]])

    # Validators
    errors = Entity.call({name: {first: 'First', middle: 'Middle'}}, result: true).data
    expect(errors.first[:field]).to eq("name.last")
  end

  it "#define_builder returns error field path for nested entity collection" do

    Entity = EntityUtils.define_builder(
      [:name, :mandatory, collection: [
         [:type, :mandatory, one_of: [:first, :middle, :last]],
         [:value, :mandatory, :string],
         [:calling_name, default: false]
       ]])

    errors = Entity.call({name: [{type: :first, value: 'First'}, {type: :second_middle, value: 'Second Middle'}]}, result: true).data

    expect(errors.first[:field]).to eq("name[1].type")
  end

  it "#define_builder returns and error code and a message" do
    Entity = EntityUtils.define_builder([:name, :string, :mandatory])

    expect(Entity.call({}, result: true).data.first[:code]).to eq :mandatory

    CustomValidatorEntity = EntityUtils.define_builder(
      [:name, validate_with: ->(v) {
         unless v == v.capitalize
           {code: :capital_letter, msg: "Value must start with capital letter. Was: #{v}"}
         end
       }])

    expect(CustomValidatorEntity.call({name: "first"}, result: true).data.first[:code]).to eq :capital_letter

  end

  it "#define_builder returns result, if result: true and does not raise an error" do
    Entity = EntityUtils.define_builder([:name, :string, :mandatory])

    result = Entity.call({name: "First Last"}, result: true)
    expect(result.success).to eq true

    result = Entity.call({}, result: true)
    expect(result.success).to eq false
  end

  it "#define_builder :callable validator" do
    Entity = EntityUtils.define_builder([:say_so, :callable])

    expect{Entity.call({say_so: -> () { "Yes, that's the way it is." }})}
      .to_not raise_error

    expect{Entity.call({say_so: nil})}
      .to_not raise_error

    expect{Entity.call({say_so: "It ain't so"})}
      .to raise_error
  end

  it "#define_builder :enumerable validator" do
    Entity = EntityUtils.define_builder([:tags, :enumerable])

    expect{Entity.call({tags: [1, 2]})}
      .to_not raise_error

    expect{Entity.call({tags: nil})}
      .to_not raise_error

    expect{Entity.call({tags: 2})}
      .to raise_error
  end

  it "define_builder :str_to_time transformer" do
    expect(EntityUtils.define_builder([:time, str_to_time: "%H:%M:%S %b %e, %Y %Z"]).call({time: "23:01:12 Sep 30, 2014 PDT"}))
      .to eq({time: Time.strptime("23:01:12 Sep 30, 2014 PDT", "%H:%M:%S %b %e, %Y %Z") })
  end

  it "define_builder :utc_str_to_time transformer" do
    timestamp = 1102856405 # 2004 12 12 13 00 05 UTC

    expect(EntityUtils.define_builder([:time, :utc_str_to_time]).call({time: "2004-12-12 13:00:05"}))
      .to eq({time: Time.at(timestamp) })
  end

  it "#define_builder :set validator" do
    Entity = EntityUtils.define_builder([:tags, :set])

    expect{Entity.call({tags: [1, 2]})}
      .to raise_error

    expect{Entity.call({tags: [1, 2].to_set})}
      .to_not raise_error

    expect{Entity.call({tags: nil})}
      .to_not raise_error
  end
end
