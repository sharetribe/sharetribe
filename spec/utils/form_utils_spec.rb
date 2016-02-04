require 'spec_helper'

describe FormUtils do
  let(:form_object) { FormUtils.define_form("NameForm", :name) }

  it "instantiates a new form from hash" do
    form = form_object.new({name: "John D.", age: 27})
    expect(form.name).to eq("John D.")
    expect { form.age }.to raise_error(NoMethodError)
  end

  it "convert to hash" do
    form = form_object.new({name: "John D.", age: 27})
    expect(form.to_hash).to eq({name: "John D."})
  end

  it "validates the form" do
    validated_form = form_object.with_validations { validates_presence_of :name }
    valid_form = validated_form.new({name: "John D.", age: 27})
    invalid_form = validated_form.new({age: 27})

    expect(valid_form.valid?).to eq(true)
    expect(invalid_form.valid?).to eq(false)
  end

  it "implements model_name" do
    expect(form_object.model_name).to eq("NameForm")
  end

end
