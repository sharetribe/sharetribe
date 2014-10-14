module PaypalService
  module Token
    PaypalTokenModel = ::PaypalToken

    module Entity
      Token = EntityUtils.define_builder(
        [:token, :string, :mandatory],
        [:transaction_id, :fixnum, :mandatory]
      )

      module_function

      def from_model(model)
        Token.call(EntityUtils.model_to_hash(model))
      end
    end

    module Command
      module_function

      def create(token, transaction_id)
        PaypalToken.create!({token: token, transaction_id: transaction_id})
      end

      def delete(token)
        PaypalToken.where(token: token).destroy_all
      end
    end

    module Query
      module_function

      def for_token(token)
        Maybe(PaypalToken.where(token: token).first)
          .map { |model| Entity.from_model(model) }
          .or_else(nil)
      end
    end
  end
end
