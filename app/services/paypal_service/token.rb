module PaypalService
  module Token
    module Command
      def save_transaction_id(token, transaction_id)
        PaypalToken.create({token: token, transaction_id: transaction_id})
      end
    end

    module Query
      def load_transaction_id(token)
        PaypalToken.where(token: token).pluck(:transaction_id).last
      end
    end
  end
end
