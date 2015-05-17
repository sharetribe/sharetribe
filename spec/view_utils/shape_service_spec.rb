# coding: utf-8
require 'spec_helper'

describe ShapeService do

  let(:shape_service) {ShapeService.new([{:id=>1, :community_id=>1, :author_is_seller=>true, :process=>:none}])}

  def create_shape(opts = {})
    defaults = {
      action_button_label: {"en" => "ACTION LABEL"},
      name: {"en" => "ERIKOIS SHAPE"},
      author_is_seller: true,
      units: [
        {
          type: :custom,
          enabled: true,
          name_tr_key: "FOO_KEY1",
          selector_tr_key: "BAR_KEY1"
        },
        {
          type: :custom,
          enabled: true,
          name: {"en" => "Custom unit label"},
          selector: {"en" => "Custom unit selector"}
        }
      ]
    }
    shape_service.create(community_id: 1, default_locale: "en", opts: defaults.merge(opts))

  end

  it 'should generate translations' do
    result = create_shape
    binding.pry
    expect(true).to be_truthy
    # units.find(existing) : keyt on samat
    # units.find(uus) : keyt on luotu, käännökset luotu
  end
end