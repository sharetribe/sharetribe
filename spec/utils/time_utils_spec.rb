require 'spec_helper'

describe TimeUtils do

  describe "#time_to" do
    it "returns the biggest unit and count" do
      now = Time.new(2015, 05, 29, 15, 13, 30).in_time_zone("EET")
      expect(TimeUtils.time_to(15.seconds.since(now), now)).to eq({unit: :seconds, count: 15})
      expect(TimeUtils.time_to(59.seconds.since(now), now)).to eq({unit: :seconds, count: 59})
      expect(TimeUtils.time_to(60.seconds.since(now), now)).to eq({unit: :minutes, count: 1})
      expect(TimeUtils.time_to(61.seconds.since(now), now)).to eq({unit: :minutes, count: 1})
      expect(TimeUtils.time_to(119.seconds.since(now), now)).to eq({unit: :minutes, count: 1})
      expect(TimeUtils.time_to(120.seconds.since(now), now)).to eq({unit: :minutes, count: 2})
      expect(TimeUtils.time_to(59.minutes.since(now), now)).to eq({unit: :minutes, count: 59})
      expect(TimeUtils.time_to(60.minutes.since(now), now)).to eq({unit: :hours, count: 1})
      expect(TimeUtils.time_to(61.minutes.since(now), now)).to eq({unit: :hours, count: 1})
      expect(TimeUtils.time_to(119.minutes.since(now), now)).to eq({unit: :hours, count: 1})
      expect(TimeUtils.time_to(120.minutes.since(now), now)).to eq({unit: :hours, count: 2})
      expect(TimeUtils.time_to(23.hours.since(now), now)).to eq({unit: :hours, count: 23})
      expect(TimeUtils.time_to(24.hours.since(now), now)).to eq({unit: :days, count: 1})
      expect(TimeUtils.time_to(25.hours.since(now), now)).to eq({unit: :days, count: 1})
      expect(TimeUtils.time_to(47.hours.since(now), now)).to eq({unit: :days, count: 1})
      expect(TimeUtils.time_to(48.hours.since(now), now)).to eq({unit: :days, count: 2})
      expect(TimeUtils.time_to(30.days.since(now), now)).to eq({unit: :days, count: 30})
    end
  end
end
