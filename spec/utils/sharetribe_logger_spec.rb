require 'spec_helper'
require_relative '../support/test_log_target'

describe SharetribeLogger do

  let(:log_target) { TestLogTarget.new }
  let(:logger) { SharetribeLogger.new(:test, log_target) }

  def test_log_level(level)
    logger.send(level, "Debug message", :debug, {debug: true})
    log = log_target.send("#{level}_log".to_sym)
    expect(log.count)
      .to eq(1)
    expect(log.first)
      .to eq({
               user_id: nil,
               username: nil,
               community_id: nil,
               community_ident: nil,
               request_uuid: nil,
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
