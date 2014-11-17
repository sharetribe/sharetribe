module MarketplaceService
  module Transaction
    TransactionModel = ::Transaction
    ParticipationModel = ::Participation

    module Entity
      Transaction = EntityUtils.define_entity(
        :id,
        :community_id,
        :last_transition,
        :last_transition_at,
        :listing,
        :discussion_type, # :offer or :request, opposite of transaction_type direction
        :status,
        :author_skipped_feedback,
        :starter_skipped_feedback,
        :starter_id,
        :testimonials,
        :transitions,
        :payment_total,
        :payment_gateway,
        :commission_from_seller,
        :conversation,
        :booking,
        :created_at,
        :__model
      )

      Transition = EntityUtils.define_entity(
        :to_state,
        :created_at,
        :metadata
      )

      Testimonial = EntityUtils.define_entity(
        :author_id,
        :receiver_id,
        :grade
      )

      ConversationEntity = MarketplaceService::Conversation::Entity
      Conversation = ConversationEntity::Conversation
      ListingEntity = MarketplaceService::Listing::Entity

      module_function

      def waiting_testimonial_from?(transaction, person_id)
        if transaction[:starter_id] == person_id
          if transaction[:starter_skipped_feedback]
            false
          else
            testimonial_from(transaction, person_id).nil?
          end
        else
          if transaction[:author_skipped_feedback]
            false
          else
            testimonial_from(transaction, person_id).nil?
          end
        end
      end

      # Params:
      # - gateway_expires_at (how long the payment authorization is valid)
      # - max_date_at (max date, e.g. booking ending)
      def preauth_expires_at(gateway_expires_at, max_date_at=nil)
        gateway_expires_at = gateway_expires_at.to_time
        max_date_at = max_date_at.to_time if max_date_at.present?

        if max_date_at.present?
          max_date_at < gateway_expires_at ? max_date_at : gateway_expires_at
        else
          gateway_expires_at
        end
      end

      def authorization_expiration_period(payment_type)
        # TODO These configs should be moved to Paypal/Braintree services
        case payment_type
        when :braintree
          APP_CONFIG.braintree_expiration_period.to_i
        when :paypal
          APP_CONFIG.paypal_expiration_period.to_i
        end
      end

      def testimonial_from(transaction, person_id)
        transaction[:testimonials].find { |testimonial| testimonial[:author_id] == person_id }
      end

      def transaction(transaction_model)
        listing_model = transaction_model.listing
        listing = ListingEntity.listing(listing_model) if listing_model

        payment_gateway = transaction_model.payment_gateway.to_sym

        payment_total =
          case payment_gateway
          when :checkout, :braintree
            # Use Maybe, since payment may not exists yet, if postpay flow
            Maybe(transaction_model).payment.total_sum.or_else { nil }
          when :paypal
            paypal_payments = PaypalService::API::Api.payments
            payment = paypal_payments.get_payment(transaction_model.community_id, transaction_model.id)

            if payment[:success]
              payment[:data][:authorization_total]
            else
              nil
            end
          end

        Transaction[EntityUtils.model_to_hash(transaction_model).merge({
          status: transaction_model.current_state,
          last_transition_at: Maybe(transaction_model.transaction_transitions.last).created_at.or_else(nil),
          listing: listing,
          testimonials: transaction_model.testimonials.map { |testimonial|
            Testimonial[EntityUtils.model_to_hash(testimonial)]
          },
          starter_id: transaction_model.starter_id,
          transitions: transaction_model.transaction_transitions.map { |transition|
            Transition[EntityUtils.model_to_hash(transition)]
          },
          discussion_type: Maybe(listing_model).discussion_type.to_sym.or_else(:not_available),
          payment_total: payment_total,
          booking: transaction_model.booking,
          __model: transaction_model
        })]
      end

      def transaction_with_conversation(transaction_model, community_id)
        transaction = Entity.transaction(transaction_model)
        if transaction_model.conversation
          transaction[:conversation] = ConversationEntity.conversation(transaction_model.conversation, community_id)
        else
          # placeholder for deleted conversation to keep transaction list working
          transaction[:conversation] = ConversationEntity.deleted_conversation_placeholder
        end
        transaction
      end

      def transition(transition_model)
        transition = Entity::Transition[EntityUtils.model_to_hash(transition_model)]
        transition[:metadata] = HashUtils.symbolize_keys(transition[:metadata]) if transition[:metadata].present?
        transition
      end
    end

    module Command

      NewTransactionOptions = EntityUtils.define_builder(
        [:community_id, :fixnum, :mandatory],
        [:listing_id, :fixnum, :mandatory],
        [:starter_id, :string, :mandatory],
        [:author_id, :string, :mandatory],
        [:content, :string, :optional],
        [:commission_from_seller, :fixnum, :optional]
      )
      module_function

      def create(transaction_opts)
        opts = NewTransactionOptions[transaction_opts]

        transaction = TransactionModel.new({
            community_id: opts[:community_id],
            listing_id: opts[:listing_id],
            starter_id: opts[:starter_id],
            commission_from_seller: opts[:commission_from_seller]})

        conversation = transaction.build_conversation(
          community_id: opts[:community_id],
          listing_id: opts[:listing_id])

        conversation.participations.build({
            person_id: opts[:author_id],
            is_starter: false,
            is_read: false})

        conversation.participations.build({
            person_id: opts[:starter_id],
            is_starter: true,
            is_read: true})

        if opts[:content].present?
          conversation.messages.build({
              content: opts[:content],
              sender_id: opts[:starter_id]})
        end

        transaction.save!

        # TODO
        # We should return Entity, without expanding all the relations
        transaction.id
      end

      # Mark transasction as unseen, i.e. something new (e.g. transition) has happened
      #
      # Under the hood, this is stored to conversation, which is not optimal since that ties transaction and
      # conversation tightly together
      def mark_as_unseen_by_other(transaction_id, person_id)
        TransactionModel.find(transaction_id)
          .conversation
          .participations
          .where("person_id != '#{person_id}'")
          .update_all(is_read: false)
      end

      def mark_as_seen_by_current(transaction_id, person_id)
        TransactionModel.find(transaction_id)
          .conversation
          .participations
          .where("person_id = '#{person_id}'")
          .update_all(is_read: true)
      end

      def transition_to(transaction_id, new_status, metadata = nil)
        new_status = new_status.to_sym
        transaction = TransactionModel.find(transaction_id)
        old_status = transaction.current_state.to_sym if transaction.current_state.present?

        transaction_entity = Entity.transaction(transaction)
        payment_type = transaction.payment_gateway.to_sym

        Events.handle_transition(transaction_entity, payment_type, old_status, new_status)

        Entity.transaction(save_transition(transaction, new_status, metadata))
      end

      def save_transition(transaction, new_status, metadata = nil)
        transaction.current_state = new_status
        transaction.save!

        metadata_hash = Maybe(metadata)
          .map { |data| TransactionService::DataTypes::TransitionMetadata.create_metadata(data) }
          .map { |data| HashUtils.compact(data) }
          .or_else(nil)

        state_machine = TransactionProcess.new(transaction, transition_class: TransactionTransition)
        state_machine.transition_to!(new_status, metadata_hash)

        transaction.touch(:last_transition_at)

        transaction.reload
      end

    end

    module Query

      module_function

      def transaction(transaction_id)
        Maybe(TransactionModel.where(id: transaction_id).first)
          .map { |m| Entity.transaction(m) }
          .or_else(nil)
      end

      def transaction_with_conversation(transaction_id, person_id, community_id)
        transaction_model = TransactionModel.joins(:listing)
          .where(id: transaction_id)
          .where(community_id: community_id)
          .includes(:booking)
          .where("starter_id = ? OR listings.author_id = ?", person_id, person_id)
          .first

        Entity.transaction_with_conversation(transaction_model, community_id)
      end

      def transactions_for_community_sorted_by_column(community_id, sort_column, sort_direction, limit, offset)
        transactions = TransactionModel
          .where(:community_id => community_id)
          .includes(:listing)
          .paginate(:page => (offset + 1), :per_page => limit)
          .order("#{sort_column} #{sort_direction}")

        transactions = transactions.map { |txn|
          Entity.transaction_with_conversation(txn, community_id)
        }
      end

      def transactions_for_community_sorted_by_activity(community_id, sort_direction, limit, offset)
        sql = sql_for_transactions_for_community_sorted_by_activity(community_id, sort_direction, limit, offset)
        transactions = TransactionModel.find_by_sql(sql)

        transactions = transactions.map { |txn|
          Entity.transaction_with_conversation(txn, community_id)
        }
      end

      def transactions_count_for_community(community_id)
        TransactionModel.where(:community_id => community_id).count
      end

      def can_transition_to?(transaction_id, new_status)
        transaction = TransactionModel.find(transaction_id)
        state_machine = TransactionProcess.new(transaction, transition_class: TransactionTransition)
        state_machine.can_transition_to?(new_status)
      end

      # TODO Consider removing to inbox service, since this is more like inbox than transaction stuff.
      def sql_for_transactions_for_community_sorted_by_activity(community_id, sort_direction, limit, offset)
        "
          SELECT transactions.* FROM transactions

          # Get 'last_transition_at'
          # (this is done by joining the transitions table to itself where created_at < created_at OR sort_key < sort_key, if created_at equals)
          LEFT JOIN conversations ON transactions.conversation_id = conversations.id
          WHERE transactions.community_id = #{community_id}
          ORDER BY
            GREATEST(COALESCE(transactions.last_transition_at, 0),
              COALESCE(conversations.last_message_at, 0)) #{sort_direction}
          LIMIT #{limit} OFFSET #{offset}
        "
      end

      @construct_last_transition_to_sql = ->(params){
      "
        SELECT id, transaction_id, to_state, created_at FROM transaction_transitions WHERE transaction_id in (#{params[:transaction_ids].join(',')})
      "
      }
    end

    module Events
      module_function

      def handle_transition(transaction, payment_type, old_status, new_status)
        if new_status == :preauthorized
          preauthorized(transaction, payment_type)
        end
      end

      # privates

      def preauthorized(transaction, payment_type)
        expiration_period = Entity.authorization_expiration_period(payment_type)
        gateway_expires_at = case payment_type
                              when :braintree
                                expiration_period.days.from_now
                              when :paypal
                                # expiration period in PayPal is an estimate,
                                # which should be quite accurate. We can get
                                # the exact time from Paypal through IPN notification. In this case,
                                # we take the 3 days estimate and add 10 minute buffer
                                expiration_period.days.from_now - 10.minutes
                              end

        booking_ends_on = Maybe(transaction)[:booking][:end_on].or_else(nil)

        expire_at = Entity.preauth_expires_at(gateway_expires_at, booking_ends_on)

        Delayed::Job.enqueue(TransactionPreauthorizedJob.new(transaction[:id]), :priority => 10)
        Delayed::Job.enqueue(AutomaticallyRejectPreauthorizedTransactionJob.new(transaction[:id]), priority: 7, run_at: expire_at)

        setup_preauthorize_reminder(transaction[:id], expire_at)
      end

      # "private" helpers

      def setup_preauthorize_reminder(transaction_id, expire_at)
        reminder_days_before = 1

        reminder_at = expire_at - reminder_days_before.day
        send_reminder = reminder_at > DateTime.now

        if send_reminder
          Delayed::Job.enqueue(TransactionPreauthorizedReminderJob.new(transaction_id), :priority => 10, :run_at => reminder_at)
        end
      end
    end
  end
end
