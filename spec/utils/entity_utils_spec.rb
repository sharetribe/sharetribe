require 'spec_helper'

describe EntityUtils do
  it "#define_entity" do
    person_entity = EntityUtils.define_entity(:name, :age)

    expect(person_entity[{name: "Peter", age: 31, likes_icecream: true}])
      .to eq({name: "Peter", age: 31})
    expect(person_entity[{name: "Peter"}])
      .to eq({name: "Peter", age: nil})
  end

  it "#define_builder" do
    person_entity = EntityUtils.define_builder(
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

    expect(person_entity[{name: "First Last", sex: :m}])
      .to eq({type: :person, name: "First Last", age: 8, sex: :m, favorite_even_number: nil, tag: nil})

    expect(person_entity[{name: "First Last", sex: :m, age: 5}])
      .to eq({type: :person, name: "First Last", age: 5, sex: :m, favorite_even_number: nil, tag: nil})

    expect(person_entity.call({name: "First Last", sex: :m, age: 5, tag: "hippy"}))
      .to eq({type: :person, name: "First Last", age: 5, sex: :m, favorite_even_number: nil, tag: :hippy})

    expect(person_entity.call({name: "First Last", sex: :m, age: 5, favorite_even_number: 4}))
      .to eq({type: :person, name: "First Last", age: 5, sex: :m, favorite_even_number: 4, tag: nil})


    # Validating

    expect{person_entity[{name: nil, sex: :m}]}
        .to raise_error(ArgumentError)

    expect{person_entity[{name: 12, sex: :m}]}
        .to raise_error(ArgumentError)

    expect{person_entity.call({name: "First Last", sex: :in_between})}
        .to raise_error(ArgumentError)

    expect{person_entity.call({name: "First Last", sex: :f, age: "12"})}
        .to raise_error(ArgumentError)

    expect{person_entity.call({name: "First Last", sex: :f, favorite_even_number: 3})}
        .to raise_error(ArgumentError)
  end

  it "#define_builder supports nested entities" do
    entity = EntityUtils.define_builder(
      [:name, :mandatory, entity: [
         [:first, :string, :mandatory],
         [:middle, :string, default: "Middle"],
         [:last, :string, :mandatory]
       ]])

    # Validators
    expect{entity.call({name: {first: 'First', last: 'Last'}})}
      .not_to raise_error

    expect{entity.call({name: {first: 'First', middle: 'Middle'}})}
      .to raise_error(ArgumentError)

    expect{entity.call({})}.to raise_error(ArgumentError)

    expect{entity.call({name: "expecting entity here"})}
      .to raise_error(ArgumentError, "Value for entity 'name' must be a Hash. Was: expecting entity here (String)")

    # Transformers
    expect(entity.call({name: {first: 'First', last: 'Last'}})).to eq({name: {first: 'First', middle: 'Middle', last: 'Last'}})

  end

  it "#define_builder handles empty nested entities" do
    entity = EntityUtils.define_builder(
      [:name, entity: [
         [:first, :string, default: "First"],
         [:middle, :string],
         [:last, :string, default: "Last"]
       ]])

    expect(entity.call({})).to eq({name: nil})
    expect(entity.call({name: {}})).to eq({name: {first: "First", middle: nil, last: "Last"}})

    default = EntityUtils.define_builder(
      [:name, default: {}, entity: [
         [:first, :string, default: "First"],
         [:middle, :string],
         [:last, :string, default: "Last"]
       ]])

    expect(default.call({})).to eq({name: {first: "First", middle: nil, last: "Last"}})
  end

  it "#define_builder can nest other builders" do
    name_details_entity = EntityUtils.define_builder(
      [:first, :string, :mandatory],
      [:middle, :string, default: "Middle"],
      [:last, :string, :mandatory]
    )

    entity = EntityUtils.define_builder(
      [:name, :mandatory, entity: name_details_entity]
    )

    # Validators
    expect{entity.call({name: {first: 'First', last: 'Last'}})}
      .not_to raise_error

    expect{entity.call({name: {first: 'First', middle: 'Middle'}})}
      .to raise_error(ArgumentError)
  end

  it "#define_builder supports nested entity collections" do
    entity = EntityUtils.define_builder(
      [:name, :mandatory, collection: [
         [:type, :mandatory, one_of: [:first, :middle, :last]],
         [:value, :mandatory, :string],
         [:calling_name, default: false]
       ]])

    # Validators
    expect{entity.call({name: [{type: :first, value: 'First'}, {type: :last, value: 'Last'}]})}
      .not_to raise_error

    expect{entity.call({name: [{type: :first, value: 'First'}, {type: :second_middle, value: 'Second Middle'}]})}
      .to raise_error(ArgumentError)

    expect{entity.call({})}.to raise_error(ArgumentError)

    expect{entity.call({name: "expecting collection here"})}
      .to raise_error(ArgumentError, "Value for collection 'name' must be an Array. Was: expecting collection here (String)")

    # Transformers
    expect(entity.call({name: [{type: :first, value: 'First', calling_name: true}, {type: :last, value: 'Last'}]}))
      .to eq({name: [{type: :first, value: 'First', calling_name: true}, {type: :last, value: 'Last', calling_name: false}]})

  end

  it "#define_builder handles empty nested collection" do
    entity = EntityUtils.define_builder(
      [:name, collection: [
         [:first, :string, default: "First"],
         [:middle, :string],
         [:last, :string, default: "Last"]
       ]])

    expect(entity.call({})).to eq({name: nil})
    expect(entity.call({name: []})).to eq({name: []})
    expect(entity.call({name: [{middle: "Middle"}]})).to eq({name: [{first: "First", middle: "Middle", last: "Last"}]})

    default = EntityUtils.define_builder(
      [:name, default: [], collection: [
         [:first, :string, default: "First"],
         [:middle, :string],
         [:last, :string, default: "Last"]
       ]])

    expect(default.call({})).to eq({name: []})
  end

  it "#define_builder accepts only symbol keys" do
    msg = ->(val, class_name) {
      "Field key must be a Symbol, was: '#{val}' (#{class_name})"
    }

    expect { EntityUtils.define_builder([nil, :string, :mandatory]) }.to raise_error( msg.call("", "NilClass") )
    expect { EntityUtils.define_builder(["key", :string, :mandatory]) }.to raise_error( msg.call("key", "String") )
    expect { EntityUtils.define_builder([:key, :string, :mandatory]) }.not_to raise_error
  end

  it "#define_builder can nest other builders for collections" do
    name_details_entity = EntityUtils.define_builder(
      [:type, :mandatory, one_of: [:first, :middle, :last]],
      [:value, :mandatory, :string],
      [:calling_name, default: false]
    )

    entity = EntityUtils.define_builder(
      [:name, :mandatory, collection: name_details_entity])

    # Validators
    expect{entity.call({name: [{type: :first, value: 'First'}, {type: :last, value: 'Last'}]})}
      .not_to raise_error

    expect{entity.call({name: [{type: :first, value: 'First'}, {type: :second_middle, value: 'Second Middle'}]})}
      .to raise_error(ArgumentError)

  end

  it "#define_builder returns error field path message for nested entities" do
    entity = EntityUtils.define_builder(
      [:name, :mandatory, entity: [
         [:first, :string, :mandatory],
         [:middle, :string, default: "Middle"],
         [:last, :string, :mandatory]
       ]])

    # Validators
    errors = entity.validate({name: {first: 'First', middle: 'Middle'}}).data
    expect(errors.first[:field]).to eq("name.last")
  end

  it "#define_builder returns error field path for nested entity collection" do

    entity = EntityUtils.define_builder(
      [:name, :mandatory, collection: [
         [:type, :mandatory, one_of: [:first, :middle, :last]],
         [:value, :mandatory, :string],
         [:calling_name, default: false]
       ]])

    errors = entity.validate({name: [{type: :first, value: 'First'}, {type: :second_middle, value: 'Second Middle'}]}).data

    expect(errors.first[:field]).to eq("name[1].type")
  end

  it "#define_builder returns and error code and a message" do
    entity = EntityUtils.define_builder([:name, :string, :mandatory])

    expect(entity.validate({}).data.first[:code]).to eq :mandatory

    CustomValidatorEntity = EntityUtils.define_builder(
      [:name, validate_with: ->(v) {
         unless v == v.capitalize
           {code: :capital_letter, msg: "Value must start with capital letter. Was: #{v}"}
         end
       }])

    expect(CustomValidatorEntity.validate({name: "first"}).data.first[:code]).to eq :capital_letter

  end

  it "#define_builder returns result, if result: true and does not raise an error" do
    entity = EntityUtils.define_builder([:name, :string, :mandatory])

    result = entity.validate({name: "First Last"})
    expect(result.success).to eq true

    result = entity.validate({})
    expect(result.success).to eq false
  end

  it "#define_builder :callable validator" do
    entity = EntityUtils.define_builder([:say_so, :callable])

    expect{entity.call({say_so: -> () { "Yes, that's the way it is." }})}
      .to_not raise_error

    expect{entity.call({say_so: nil})}
      .to_not raise_error

    expect{entity.call({say_so: "It ain't so"})}
      .to raise_error(ArgumentError)
  end

  it "#define_builder :enumerable validator" do
    entity = EntityUtils.define_builder([:tags, :enumerable])

    expect{entity.call({tags: [1, 2]})}
      .to_not raise_error

    expect{entity.call({tags: nil})}
      .to_not raise_error

    expect{entity.call({tags: 2})}
      .to raise_error(ArgumentError)
  end

  it "#define builder :range validator" do
    entity = EntityUtils.define_builder([:price, :range])

    expect(entity.validate({price: nil}).success).to eq(true)
    expect(entity.validate({price: (1..2)}).success).to eq(true)

    expect(entity.validate({price: [1, 2]}).success).to eq(false)
    expect(entity.validate({price: [1, 2]}).data.first[:code]).to eq(:range)

    expect(entity.validate({price: {a: 1}}).success).to eq(false)
    expect(entity.validate({price: {a: 1}}).data.first[:code]).to eq(:range)

    expect(entity.validate({price: 1}).success).to eq(false)
    expect(entity.validate({price: 1}).data.first[:code]).to eq(:range)
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
    entity = EntityUtils.define_builder([:tags, :set])

    expect{entity.call({tags: [1, 2]})}
      .to raise_error(ArgumentError)

    expect{entity.call({tags: [1, 2].to_set})}
      .to_not raise_error

    expect{entity.call({tags: nil})}
      .to_not raise_error
  end

  it "#define_builder gt validator" do
    entity = EntityUtils.define_builder([:num, gt: 0])

    expect(entity.validate({num: -1}).success).to eq false
    expect(entity.validate({num: -1}).data.first[:code]).to eq :gt

    expect(entity.validate({num: 0}).success).to eq false
    expect(entity.validate({num: 0}).data.first[:code]).to eq :gt

    expect(entity.validate({num: 1}).success).to eq true
  end

  it "#define_builder gte validator" do
    entity = EntityUtils.define_builder([:num, gte: 0])

    expect(entity.validate({num: -1}).success).to eq false
    expect(entity.validate({num: -1}).data.first[:code]).to eq :gte

    expect(entity.validate({num: 0}).success).to eq true

    expect(entity.validate({num: 1}).success).to eq true
  end

  it "#define_builder lt validator" do
    entity = EntityUtils.define_builder([:num, lt: 0])

    expect(entity.validate({num: -1}).success).to eq true

    expect(entity.validate({num: 0}).success).to eq false
    expect(entity.validate({num: 0}).data.first[:code]).to eq :lt

    expect(entity.validate({num: 1}).success).to eq false
    expect(entity.validate({num: 1}).data.first[:code]).to eq :lt
  end

  it "#define_builder lte validator" do
    entity = EntityUtils.define_builder([:num, lte: 0])

    expect(entity.validate({num: -1}).success).to eq true

    expect(entity.validate({num: 0}).success).to eq true

    expect(entity.validate({num: 1}).success).to eq false
    expect(entity.validate({num: 1}).data.first[:code]).to eq :lte
  end

  it "#define_builder is fast" do
    enable_test = false
    if enable_test # You can enable this test to measure the performance

      name_details_entity = EntityUtils.define_builder(
        [:first, :string, :mandatory],
        [:middle, :string, default: "Middle"],
        [:last, :string, :mandatory]
      )

      entity = EntityUtils.define_builder(
        [:name, :mandatory, entity: name_details_entity]
      )
      bm = 1000 * Benchmark.realtime {
        1000.times {
          entity.call(
            {
              name: {
                first: "John",
                last: "Doe"
              }
            }
          )
        }
      }

      expect(bm).to be < 0

    end
  end

  describe "#serializes" do
    let(:name_details_entity) {
      EntityUtils.define_builder(
          [:first, :string, :mandatory],
          [:middle, :string, default: "Middle"],
          [:last, :string, :mandatory]
        )
    }

    context "success" do
      it "serializes to JSON" do
        expect(name_details_entity.serialize(first: "John", last: "Doe")).to eq("{\"first\":\"John\",\"middle\":\"Middle\",\"last\":\"Doe\"}")
      end
    end

    context "failure" do
      it "validates the input and fails for invalid" do
        expect { name_details_entity.serialize(first: "John") }.to raise_error(ArgumentError)
      end
    end

    it "serializing and deserializing gives original value" do
      original = name_details_entity.call({ first: "John", last: "Doe" })
      expect(name_details_entity.deserialize(name_details_entity.serialize(original))).to eq original
    end
  end

  describe "#deserializes" do
    let(:name_details_entity) {
      EntityUtils.define_builder(
          [:first, :string, :mandatory],
          [:middle, :string, default: "Middle"],
          [:last, :string, :mandatory]
        )
    }

    context "success" do
      it "deserializes from JSON" do
        expect(name_details_entity.deserialize("{\"first\":\"Jane\",\"last\":\"Doe\"}")).to eq({first: "Jane", middle: "Middle", last: "Doe"})
      end
    end

    context "failure" do
      it "validates the input and fails for invalid" do
        expect { name_details_entity.deserialize("{\"first\":\"Jane\"}") }.to raise_error(ArgumentError)
      end
    end
  end
end
