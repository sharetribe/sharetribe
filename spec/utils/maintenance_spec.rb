describe Maintenance do
  describe "self.parse_time_from_env" do
    it "accepts nil, Time and String" do
      expect(Maintenance.parse_time_from_env(Time.utc(2016, 3, 21, 12, 0, 0)))
        .to eq(Time.utc(2016, 3, 21, 12, 0, 0))

      expect(Maintenance.parse_time_from_env("2016-03-21 12:00:00 +0200"))
        .to eq(Time.utc(2016, 3, 21, 10, 0, 0))

      expect(Maintenance.parse_time_from_env(nil))
        .to eq(nil)
    end
  end

  describe "show_warning?" do

    context "next maintenance scheduled" do

      let(:next_at) { Time.utc(2016, 3, 21, 12, 0, 0) }
      let(:next_maintenance) { Maintenance.new(next_at) }

      it "returns false if too early to show the warning" do
        expect(next_maintenance.show_warning?(
                15.minutes, Time.utc(2016, 3, 21, 11, 0, 0)))
          .to eq(false)
      end

      it "returns true if it's time to show the warning" do
        expect(next_maintenance.show_warning?(
                15.minutes, Time.utc(2016, 3, 21, 11, 55, 0)))
          .to eq(true)
      end

      it "returns true if the time is in the past" do
        expect(next_maintenance.show_warning?(
                15.minutes, Time.utc(2016, 3, 21, 12, 05, 0)))
          .to eq(true)
      end
    end

    context "no maintenance scheduled" do

      let(:next_at) { "" }
      let(:next_maintenance) { Maintenance.new(next_at) }

      it "returns always false" do
        expect(next_maintenance.show_warning?(
                15.minutes, Time.utc(2016, 3, 21, 11, 55, 0)))
          .to eq(false)
      end
    end
  end

  describe "minutes to" do

    context "next maintenance scheduled" do

      let(:next_at) { Time.utc(2016, 3, 21, 12, 0, 0) }
      let(:next_maintenance) { Maintenance.new(next_at) }

      it "returns minutes to next maintenance" do
        expect(next_maintenance.minutes_to(Time.utc(2016, 3, 21, 11, 55, 0)))
          .to eq(5)

        expect(next_maintenance.minutes_to(Time.utc(2016, 3, 21, 11, 59, 0)))
          .to eq(1)

        expect(next_maintenance.minutes_to(Time.utc(2016, 3, 21, 12, 0, 0)))
          .to eq(0)
      end

      it "returns zero if next maintenance is in the past" do
        expect(next_maintenance.minutes_to(Time.utc(2016, 3, 21, 12, 1, 0)))
          .to eq(0)
      end
    end

    context "no maintenance scheduled" do

      let(:next_at) { "" }
      let(:next_maintenance) { Maintenance.new(next_at) }

      it "returns always 0" do
        expect(next_maintenance.minutes_to(Time.utc(2016, 3, 21, 11, 55, 0)))
          .to eq(0)
      end
    end
  end
end
