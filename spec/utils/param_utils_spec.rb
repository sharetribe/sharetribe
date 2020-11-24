require 'spec_helper'

describe ParamUtils do
  it "#throw_if_any_empty" do
    expect{ ParamUtils.throw_if_any_empty({foo: nil}) }.to raise_error(ArgumentError)
    expect{ ParamUtils.throw_if_any_empty({foo: ""}) }.to raise_error(ArgumentError)
    expect{ ParamUtils.throw_if_any_empty({foo: 1 }) }.to_not raise_error
  end
end
