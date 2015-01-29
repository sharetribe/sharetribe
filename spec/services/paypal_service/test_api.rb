module PaypalService

  class TestApi
    attr_reader :config
    SuccessResponse = Struct.new(:success?, :value)
    ErrorResponse = Struct.new(:success?, :errors)
    Error = Struct.new(:error_code, :long_message)

    Config = Struct.new(:subject)

    def initialize(subject, should_fail = false, error_code = nil)
      @config = Config.new(subject || "test_username")
      @should_fail = should_fail
      @error_code = error_code
    end

    def wrap(val)
      unless @should_fail
        SuccessResponse.new(true, val)
      else
        ErrorResponse.new(false, [Error.new(@error_code, "error msg")])
      end
    end

    def do_nothing(val)
      val
    end
  end

  class TestApiBuilder
    def initialize()
      # We maintain a queue of next response type, elems are :ok or "error_code".
      # Empty queue implicitly means :ok
      @next_responses = []
    end

    def will_respond_with(response_types)
      @next_responses = response_types
    end

    def will_fail(times, error_code)
      will_respond_with(times.times.map { error_code })
    end

    def call(req)
      res_type = @next_responses.shift
      if (res_type.is_a? String)
        TestApi.new(req[:receiver_username], true, res_type)
      else
        TestApi.new(req[:receiver_username])
      end
    end
  end

  class FakePal
    def initialize
      @tokens = {}
      @payments_by_order_id = {}
      @payments_by_auth_id = {}
    end

    def save_token(req)
      token = {
        token: SecureRandom.uuid,
        item_name: req[:item_name],
        item_quantity: req[:item_quantity],
        item_price: req[:item_price],
        order_total: req[:order_total],
        receiver_id: req[:receiver_username]
      }

      @tokens[token[:token]] = token
      token
    end

    def get_token(token)
      @tokens[token]
    end

    def create_and_save_payment(token)
      payment = {
        order_date: Time.now,
        payment_status: "pending",
        pending_reason: "order",
        order_id: SecureRandom.uuid,
        order_total: token[:order_total],
        receiver_id: token[:receiver_id]
      }

      @payments_by_order_id[payment[:order_id]] = payment
      payment
    end

    def authorize_payment(order_id, authorization_total)
      payment = @payments_by_order_id[order_id]
      raise "No order with order id: #{order_id}" if payment.nil?
      raise "Cannot authorize more than order_total" if authorization_total.cents > payment[:order_total].cents

      auth_id = SecureRandom.uuid
      auth_payment = payment.merge({
        authorization_date: Time.now,
        authorization_total: authorization_total,
        authorization_id: auth_id,
        payment_status: "pending",
        pending_reason: "authorization",
        })

      @payments_by_order_id[order_id] = auth_payment
      @payments_by_auth_id[auth_id] = auth_payment
      auth_payment
    end

    def capture_payment(auth_id, payment_total)
      payment = @payments_by_auth_id[auth_id]
      raise "No payment for auth id: #{auth_id}" if payment.nil?
      raise "Cannot capture more than authorization_total" if payment_total.cents > payment[:authorization_total].cents

      payment_id = SecureRandom.uuid
      captured_payment = payment.merge({
          payment_id: payment_id,
          payment_total: payment_total,
          fee_total: Money.new((payment_total.cents*0.1).to_i, payment_total.currency.iso_code),
          payment_date: Time.now,
          payment_status: "completed",
          pending_reason: "none"
        })
    end

    def get_payment(auth_or_order_id)
      @payments_by_auth_id[auth_or_order_id] || @payments_by_order_id[auth_or_order_id]
    end

    def void(auth_or_order_id)
      payment = get_payment(auth_or_order_id)
      raise "No payment with order or auth id: #{auth_or_order_id}" if payment.nil?

      voided_payment = payment.merge({
          payment_status: "voided",
          pending_reason: "none"
        })

      @payments_by_order_id[voided_payment[:order_id]] = voided_payment
      @payments_by_auth_id[voided_payment[:authorization_id]] = voided_payment unless voided_payment[:authorization_id].nil?
      voided_payment
    end
  end
end
