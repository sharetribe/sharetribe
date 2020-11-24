require 'spec_helper'

describe UUIDUtils do

  describe "#parse_raw and #raw" do

    # Using MySQL connection (the `raw_connection`) because I didn't find a way
    # to do prepared statements with just the `connection` object.
    # Prepared statement seems to be the way to store binary data.
    #
    let(:mysql_conn) { ActiveRecord::Base.connection.raw_connection }

    before(:each) do
      mysql_conn.prepare("
        CREATE TEMPORARY TABLE `uuid_utils_test` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `uuid` binary(16) NOT NULL,
          PRIMARY KEY (`id`)
        )").execute
    end

    # Takes UUID and returns the time component
    # which is the first 18 (16 chars + 2 dashes) chars
    def time_component(uuid_string)
      uuid_string.to_s.first(18)
    end

    it "parses back and forth" do
      now = Time.now
      sorted_uuids = (1..100).map { |i|
        # Give the timestamp as an argument.
        # This ensures that two timestamps are not generated with
        # the same timestamp
        UUIDTools::UUID.timestamp_create(now + i)
      }
      shuffled_uuids = sorted_uuids.shuffle
      shuffled_uuids_raw = shuffled_uuids.map { |uuid| UUIDUtils.raw(uuid) }

      expect(shuffled_uuids_raw.map { |raw_uuid| UUIDUtils.parse_raw(raw_uuid) }).to eq(shuffled_uuids)

      shuffled_uuids_raw.each { |raw_uuid|
        statement = mysql_conn.prepare("INSERT INTO uuid_utils_test (uuid) VALUES (?)")
        statement.execute(raw_uuid)
      }

      db_uuids = mysql_conn.query("SELECT uuid FROM uuid_utils_test ORDER BY uuid").map { |row|
        raw_uuid = row.first
        UUIDUtils.parse_raw(raw_uuid)
      }

      # Make sure all generated UUIDs have different time component
      expect(sorted_uuids.map { |uuid| time_component(uuid) }.uniq)
        .to eq(sorted_uuids.map { |uuid| time_component(uuid) })

      expect(db_uuids).to eq(sorted_uuids)
    end
  end
end
