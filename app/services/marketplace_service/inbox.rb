module MarketplaceService
  module Inbox
    module Entity
      module_function

      # Move to ListingService
      def discussion_type(transaction_type)
        offers = ["Give", "Lend", "Rent", "Sell", "Service", "ShareForFree", "Swap", "Offer"]
        requests = ["Request"]
        inqueries = ["Inquiry"]

        if offers.include?(transaction_type)
          "request" # If listing is offer, the discussion type is opposite, i.e. request
        elsif requests.include?(transaction_type)
          "offer"
        elsif inqueries.include?(transaction_type)
          "inquiry"
        else
          raise("Unknown listing type: #{transaction_type}")
        end
      end

      def last_activity_type(inbox_item)
        message_was_last = if inbox_item[:last_transition_at].nil?
          :message
        elsif inbox_item[:last_message_at].nil?
          :transition
        elsif inbox_item[:last_transition_to_state] == "free" || inbox_item[:last_transition_to_state] == "pending"
          # Ignore "free" and "pending" transitions
          :message
        else
          if inbox_item[:last_message_at] > inbox_item[:last_transition_at]
            :message
          else
            :transition
          end
        end
      end
    end

    module Command

    end

    module Query
      PersonModel = ::Person

      module_function

      def inbox_data_count(person_id, community_id)
        QueryHelper.query_inbox_data_count(person_id, community_id)
      end

      def inbox_data(person_id, community_id, limit, offset)
        QueryHelper.query_inbox_data(person_id, community_id, limit, offset)
      end
    end

    module QueryHelper
      PersonModel = ::Person

      common_sql_opts = [
        [:conversation_id, :fixnum, :mandatory],
        [:last_activity_at, :str_to_time, :mandatory],
        [:current_is_read, :int_to_bool, :mandatory],
        [:current_is_starter, :int_to_bool, :mandatory],
        [:current_id, :string, :mandatory],
        [:other_id, :string, :mandatory]
      ]

      conversation_sql_opts = [
        [:type, const_value: :conversation],
        [:last_message_at, :time, :mandatory],
        [:last_message_content, :string, :mandatory]
      ]

      transaction_sql_opts = [
        [:type, const_value: :transaction],
        [:transaction_id, :fixnum, :mandatory],

        [:listing_id, :fixnum, :mandatory],
        [:listing_title, :string, :mandatory],
        [:transaction_type, :string, :mandatory],
        [:current_user_testimonial_id, :fixnum, :optional],

        [:last_transition_at, :time, :mandatory],
        [:last_transition_to_state, :string, :mandatory],
        [:last_message_at, :time, :optional],
        [:last_message_content, :string, :optional],

        [:sum_cents, :fixnum, :optional],
        [:currency, :string, :optional],

        [:author_skipped_feedback, :int_to_bool, :mandatory],
        [:starter_skipped_feedback, :int_to_bool, :mandatory]
      ]

      SQLResultConversation = EntityUtils.define_builder(*common_sql_opts, *conversation_sql_opts)
      SQLResultTransaction = EntityUtils.define_builder(*common_sql_opts, *transaction_sql_opts)

      extended_common_opts = [
        [:starter, :hash, :mandatory],
        [:current, :hash, :mandatory],
        [:other, :hash, :mandatory]
      ]

      extended_transaction_opts = [
        [:author, :hash, :mandatory],
        [:waiting_feedback, :int_to_bool, :mandatory],
        [:transitions, :mandatory] # Could add Array validation
      ]

      ExtendedConvesationResult = EntityUtils.define_builder(*common_sql_opts, *conversation_sql_opts, *extended_common_opts)
      ExtendedTransactionResult = EntityUtils.define_builder(*common_sql_opts, *transaction_sql_opts, *extended_common_opts, *extended_transaction_opts)

      module_function

      def query_inbox_data(person_id, community_id, limit, offset)
        sql = construct_sql(person_id, community_id, limit, offset)
        result_set = ActiveRecord::Base.connection.execute(sql).each(as: :hash).map { |row| EntityUtils.hash_keys_to_symbols(row) }

        people_ids = HashUtils.pluck(result_set, :current_id, :other_id).uniq
        people_cache = MarketplaceService::Person::Query.people(people_ids)

        result_set.map do |result|
          if result[:transaction_id].present?
            ExtendedTransactionResult[extend_transaction(extend_people(SQLResultTransaction[result], people_cache))]
          else
            ExtendedConvesationResult[extend_conversation(extend_people(SQLResultConversation[result], people_cache))]
          end
        end
      end

      def query_inbox_data_count(person_id, community_id)
        ActiveRecord::Base.connection.select_value(construct_count_sql(person_id, community_id))
      end

      def extend_people(common, people)
        current_id = common[:current_id]
        other_id   = common[:other_id]
        starter_id = common[:current_is_starter] ? common[:current_id] : common[:other_id]

        common.merge(
          starter: people[starter_id],
          other: people[other_id],
          current: people[current_id]
        )
      end

      def extend_conversation(conversation)
        # No-op
        conversation
      end

      def extend_transaction(transaction)
        current_skipped_feedback = transaction[:current_is_starter] ? transaction[:starter_skipped_feedback] : transaction[:author_skipped_feedback]
        current_has_given_feedback = transaction[:current_user_testimonial_id].present?

        transitions = TransactionTransition.where(transaction_id: transaction[:transaction_id]).map do |transition_model|
          MarketplaceService::Transaction::Entity::Transition[EntityUtils.model_to_hash(transition_model)]
        end

        transaction.merge(
          author: transaction[:other],
          waiting_feedback: !(current_skipped_feedback || current_has_given_feedback),
          transitions: transitions
        )
      end

      # Construct query for
      # - person
      # - community
      # - sorted by last acticity
      # - with pagination
      def construct_sql(person_id, community_id, limit, offset)
        "
          SELECT
            transactions.id AS transaction_id,
            conversations.id AS conversation_id,
            m.last_message_at,
            m.last_message_content,
            tt.last_transition_at,
            tt.last_transition_to_state,
            GREATEST(COALESCE(tt.last_transition_at, 0),
              COALESCE(m.last_message_at, 0))                 AS last_activity_at,
            listings.id                                       AS listing_id,
            listings.title                                    AS listing_title,
            listings.author_id                                AS author_id,
            payments.sum_cents                                AS sum_cents,
            payments.currency                                 AS currency,
            transaction_types.type                            AS transaction_type,
            transactions.author_skipped_feedback              AS author_skipped_feedback,
            transactions.starter_skipped_feedback             AS starter_skipped_feedback,
            current_participation.is_read                     AS current_is_read,
            current_participation.is_starter                  AS current_is_starter,
            current_participation.person_id                   AS current_id,
            other_participation.person_id                     AS other_id,
            testimonials.id                                   AS current_user_testimonial_id
          FROM conversations

          LEFT JOIN transactions      ON transactions.conversation_id = conversations.id
          LEFT JOIN listings          ON transactions.listing_id = listings.id
          LEFT JOIN transaction_types ON listings.transaction_type_id = transaction_types.id
          LEFT JOIN payments          ON payments.transaction_id = transactions.id
          LEFT JOIN testimonials      ON (testimonials.transaction_id = transactions.id AND testimonials.author_id = '#{person_id}')
          LEFT JOIN participations    AS current_participation ON (current_participation.conversation_id = conversations.id AND current_participation.person_id = '#{person_id}')
          LEFT JOIN participations    AS other_participation ON (other_participation.conversation_id = conversations.id AND other_participation.person_id != '#{person_id}')

          # Get 'last_transition_at' and 'last_transition_to_state'
          # (this is done by joining the transitions table to itself where created_at < created_at OR sort_key < sort_key, if created_at equals)
          LEFT JOIN (
            SELECT tt1.transaction_id, tt1.created_at as last_transition_at, tt1.to_state as last_transition_to_state
            FROM transaction_transitions tt1
            LEFT JOIN transaction_transitions tt2 ON tt1.transaction_id = tt2.transaction_id AND (tt1.created_at < tt2.created_at OR tt1.sort_key < tt2.sort_key)
            WHERE tt2.id IS NULL
          ) AS tt ON (transactions.id = tt.transaction_id)

          # Get 'last_message_at' and 'last_message_content'
          # (this is done by joining the messages table to itself where created_at < created_at)
          LEFT JOIN (
            SELECT m1.conversation_id, m1.created_at as last_message_at, m1.content as last_message_content
            FROM messages m1
            LEFT JOIN messages m2 ON m1.conversation_id = m2.conversation_id AND m1.created_at < m2.created_at
            WHERE m2.id IS NULL
          ) AS m ON (conversations.id = m.conversation_id)

          # Where person and community
          WHERE conversations.community_id = #{community_id}
          AND ((current_participation.person_id = '#{person_id}') OR (other_participation.person_id = '#{person_id}'))

          # Order by 'last_activity_at', that is last message or last transition
          ORDER BY last_activity_at DESC

          # Pagination
          LIMIT #{limit} OFFSET #{offset}
        "
      end

      def construct_count_sql(person_id, community_id)
        "
          SELECT COUNT(*)
          FROM conversations

          LEFT JOIN participations    AS current_participation ON (current_participation.conversation_id = conversations.id AND current_participation.person_id = '#{person_id}')
          LEFT JOIN participations    AS other_participation ON (other_participation.conversation_id = conversations.id AND other_participation.person_id != '#{person_id}')

          # Where person and community
          WHERE conversations.community_id = #{community_id}
          AND ((current_participation.person_id = '#{person_id}') OR (other_participation.person_id = '#{person_id}'))
        "
      end

    end
  end
end
