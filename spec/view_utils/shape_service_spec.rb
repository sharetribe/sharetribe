# coding: utf-8
require 'spec_helper'

describe ShapeService do

  let(:shape_service) {ShapeService.new([ TransactionProcess.new({:id=>1, :community_id=>1, :author_is_seller=>true, :process=>:none})])}

  def create_shape(opts = {})
    defaults = {
      action_button_label: {"en" => "ACTION LABEL"},
      name: {"en" => "SPECIAL SHAPE"},
      author_is_seller: true,
      units: [
        {
          unit_type: 'custom',
          kind: 'time',
          enabled: true,
          name_tr_key: "FOO_KEY1",
          selector_tr_key: "BAR_KEY1"
        },
        {
          unit_type: 'custom',
          kind: 'quantity',
          enabled: true,
          name: {"en" => "Custom unit label"},
          selector: {"en" => "Custom unit selector"}
        }
      ]
    }
    shape_service.create(community: Community.find(1), default_locale: "en", opts: defaults.merge(opts))

  end

  context "when processing a shape for creating" do
    it 'missing translations for units are created' do
      result = create_shape
      units = result.data.units
      units.each{|unit|
        expect(unit).to include(:name_tr_key)
        expect(unit).to include(:selector_tr_key)
      }
    end
    it "existing translations are untouched" do
      result = create_shape
      units = result.data.units
      expect(units.find{|unit| unit[:name_tr_key] == "FOO_KEY1" && unit[:selector_tr_key] == "BAR_KEY1"}).not_to be_empty
    end
  end
end
