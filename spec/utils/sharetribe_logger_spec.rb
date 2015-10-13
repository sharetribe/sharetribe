require 'spec_helper'
require_relative '../support/test_log_target'

describe SharetribeLogger do

  let(:log_target) { TestLogTarget.new }

  describe "log levels" do
    let(:logger) { SharetribeLogger.new(:test, [], log_target) }

    def test_log_level(level)
      logger.send(level, "Debug message", :debug, {debug: true})
      log = log_target.send("#{level}_log".to_sym)
      expect(log.count)
        .to eq(1)
      expect(log.first)
        .to eq({
                 tag: :test,
                 free: "Debug message",
                 type: :debug,
                 structured: {debug: true}
               }.to_json)

    end

    it "logs debug level messages" do
      test_log_level(:debug)
    end

    it "logs warn level messages" do
      test_log_level(:warn)
    end

    it "logs info level messages" do
      test_log_level(:info)
    end

    it "logs error level messages" do
      test_log_level(:error)
    end
  end

  describe "#add_metadata" do
    let(:logger) { SharetribeLogger.new(:test, [:community_id, :community_ident, :user_id, :username], log_target) }

    it "includes metadata" do
      logger.add_metadata(community_id: 123, community_ident: "ident")
      logger.add_metadata(user_id: "abc")
      logger.info("Message")

      expect(log_target.info_log.first)
        .to eq({
                 community_id: 123,
                 community_ident: "ident",
                 user_id: "abc",
                 tag: :test,
                 free: "Message"
               }.to_json)
    end

    it "throws for unknown metadata keys" do

      expect { logger.add_metadata(community_id: 123) }
        .not_to raise_error

      expect { logger.add_metadata(community_id: 123, unknown: "jes") }
        .to raise_error(ArgumentError, "Unknown metadata keys: [:unknown]")

      expect { logger.add_metadata(community_id: 123, community_ident: "ident", user_id: 123, username: "user", unknown: "jes") }
        .to raise_error(ArgumentError, "Unknown metadata keys: [:unknown]")
    end
  end
end
