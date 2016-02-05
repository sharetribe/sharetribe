require 'spec_helper'

describe Events do

  it "#send triggers all registered callbacks" do
    foo_c = 0
    bar_c = 0

    events = Events.new({
        foo: -> (inc1, inc2) { foo_c += (inc1 + inc2) },
        bar: [-> (inc) { bar_c += inc}, -> (inc) { bar_c += inc }]
      })

    events.send(:foo, 2, 3)
    events.send(:bar, 1)
    events.send(:bar, 1)

    expect(foo_c).to eq 5
    expect(bar_c).to eq 4
  end

  it "#send raises error if called for unknown event" do
    events = Events.new()

    expect { events.send(:doo, "payload msg") }
      .to raise_error(ArgumentError, "Unknown event: doo")
  end

end
