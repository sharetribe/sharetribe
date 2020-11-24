[
  "app/utils/service_client/middleware/middleware_base",
  "app/utils/service_client/middleware/retry",
].each { |file| require_relative "../../../../#{file}" }

require 'pry'

describe ServiceClient::Middleware::Retry do

  let(:mw) { ServiceClient::Middleware::Retry.new(max_attempts: 3) }

  describe "#enter" do

    it "initializes attempts" do
      ctx = mw.enter(req: {}, enter_queue: [])
      expect(ctx[:req][:attempts]).to eq(1)
    end

    it "increments attempts" do
      ctx = mw.enter(req: { attempts: 2}, enter_queue: [])
      expect(ctx[:req][:attempts]).to eq(3)
    end

    it "copies the enter_queue to retry_queue" do
      ctx = mw.enter(req: {}, enter_queue: [:mw1, :mw2])
      expect(ctx[:enter_queue]).to eq([:mw1, :mw2])
      expect(ctx[:retry_queue]).to eq([:mw1, :mw2, mw])
    end
  end

  describe "#leave" do

    it "returns unmodified ctx if successful" do
      new_ctx = mw.leave(req: { attempts: 1 },
                         res: { status: 200 },
                         opts: {},
                         enter_queue: [],
                         retry_queue: [1, 2, 3])

      expect(new_ctx).to eq(req: { attempts: 1},
                            res: { status: 200 },
                            opts: {},
                            enter_queue: [],
                            retry_queue: [1, 2, 3])
    end

    it "retries if the status is 5xx" do
      new_ctx = mw.leave(req: { attempts: 1 },
                         res: { status: 500 },
                         opts: {},
                         enter_queue: [],
                         retry_queue: [1, 2, 3])

      expect(new_ctx).to include(req: { attempts: 1 },
                                 res: { status: 500 },
                                 opts: {},
                                 enter_queue: [1, 2, 3],
                                 retry_queue: [1, 2, 3])
    end

    it "doesn't retry for 4xx statuses" do
      new_ctx = mw.leave(req: { attempts: 1 },
                         res: { status: 404 },
                         opts: {},
                         enter_queue: [],
                         retry_queue: [1, 2, 3])

      expect(new_ctx).to include(req: { attempts: 1 },
                                 res: { status: 404 },
                                 opts: {},
                                 enter_queue: [],
                                 retry_queue: [1, 2, 3])
    end

    it "doesn't retry if max number of attempts has been made" do
      new_ctx = mw.leave(req: { attempts: 3 },
                         res: { status: 500 },
                         opts: {},
                         enter_queue: [],
                         retry_queue: [1, 2, 3])

      expect(new_ctx).to eq(req: { attempts: 3 },
                            res: { status: 500 },
                            opts: {},
                            enter_queue: [],
                            retry_queue: [1, 2, 3])
    end

    it "doesn't retry if max number of attempts (from opts) has been made" do
      new_ctx = mw.leave(req: { attempts: 5 },
                         res: { status: 500 },
                         opts: { max_attempts: 5 },
                         enter_queue: [],
                         retry_queue: [1, 2, 3])

      expect(new_ctx).to eq(req: { attempts: 5 },
                            res: { status: 500 },
                            opts: { max_attempts: 5 },
                            enter_queue: [],
                            retry_queue: [1, 2, 3])
    end

  end

  describe "#error" do

    it "retries and removes the error if unsuccessful" do
      new_ctx = mw.error(req: { attempts: 1 },
                         res: {},
                         error: ArgumentError.new("Some error"),
                         opts: {},
                         enter_queue: [],
                         retry_queue: [1, 2, 3])

      expect(new_ctx).to eq(req: { attempts: 1 },
                            res: {},
                            error: nil,
                            opts: {},
                            enter_queue: [1, 2, 3],
                            retry_queue: [1, 2, 3])

    end
  end
end
