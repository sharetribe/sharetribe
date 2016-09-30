[
  "app/utils/service_client/middleware/middleware_base",
  "app/utils/service_client/middleware/retry",
].each { |file| require_relative "../../../../#{file}" }

require 'pry'

describe ServiceClient::Middleware::Retry do

  let(:mw) { ServiceClient::Middleware::Retry.new(max_attempts: 3) }

  describe "#enter" do

    it "initializes attempts" do
      ctx = mw.enter(req: {})
      expect(ctx[:req][:attempts]).to eq(1)
    end

    it "increments attempts" do
      ctx = mw.enter(req: { attempts: 2})
      expect(ctx[:req][:attempts]).to eq(3)
    end
  end

  describe "#leave" do

    it "returns unmodified ctx if successful" do
      new_ctx = mw.leave(req: { attempts: 1 },
                         res: { success: true },
                         opts: {},
                         enter_queue: [],
                         complete_stack: [1, 2, 3])

      expect(new_ctx).to eq(req: { attempts: 1},
                            res: { success: true },
                            opts: {},
                            enter_queue: [],
                            complete_stack: [1, 2, 3])
    end

    it "retries if unsuccessful" do
      new_ctx = mw.leave(req: { attempts: 1 },
                         res: { success: false },
                         opts: {},
                         enter_queue: [],
                         complete_stack: [1, 2, 3])

      expect(new_ctx).to eq(req: { attempts: 1 },
                            res: { success: false },
                            opts: {},
                            enter_queue: [3, 2, 1],
                            complete_stack: [])

    end

    it "doesn't retry if max number of attempts has been made" do
      new_ctx = mw.leave(req: { attempts: 3 },
                         res: { success: false },
                         opts: {},
                         enter_queue: [],
                         complete_stack: [1, 2, 3])

      expect(new_ctx).to eq(req: { attempts: 3 },
                            res: { success: false },
                            opts: {},
                            enter_queue: [],
                            complete_stack: [1, 2, 3])
    end

    it "doesn't retry if max number of attempts (from opts) has been made" do
      new_ctx = mw.leave(req: { attempts: 5 },
                         res: { success: false },
                         opts: { max_attempts: 5 },
                         enter_queue: [],
                         complete_stack: [1, 2, 3])

      expect(new_ctx).to eq(req: { attempts: 5 },
                            res: { success: false },
                            opts: { max_attempts: 5 },
                            enter_queue: [],
                            complete_stack: [1, 2, 3])
    end

  end

  describe "#error" do

    it "retries and removes the error if unsuccessful" do
      new_ctx = mw.error(req: { attempts: 1 },
                         res: { success: false },
                         error: ArgumentError.new("Some error"),
                         opts: {},
                         enter_queue: [],
                         complete_stack: [1, 2, 3])

      expect(new_ctx).to eq(req: { attempts: 1 },
                            res: { success: false },
                            error: nil,
                            opts: {},
                            enter_queue: [3, 2, 1],
                            complete_stack: [])

    end
  end
end
