module MarketplaceService
  module Inbox
    module Entity
      module_function

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

      def notification_count(person_id, community_id)
        QueryHelper.query_notification_count(person_id, community_id)
      end
    end

    module QueryHelper
      PersonModel = ::Person

      @tiny_int_to_bool = ->(tiny_int) {
        !(tiny_int.nil? || tiny_int == 0)
      }

      common_spec = [
        [:conversation_id, :fixnum, :mandatory],
        [:last_activity_at, :str_to_time, :mandatory],
        [:current_is_starter, :mandatory, transform_with: @tiny_int_to_bool],
        [:current_id, :string, :mandatory],
        [:other_id, :string, :mandatory],

        [:should_notify, :mandatory],

        [:starter, :hash, :mandatory],
        [:current, :hash, :mandatory],
        [:other, :hash, :mandatory]
      ]

      conversation_spec = [
        [:type, const_value: :conversation],
        [:last_message_at, :time, :mandatory],
        [:last_message_content, :string, :mandatory]
      ]

      transaction_spec = [
        [:type, const_value: :transaction],
        [:transaction_id, :fixnum, :mandatory],

        [:listing_id, :fixnum, :mandatory],
        [:listing_title, :string, :mandatory],
        [:transaction_type, :string, :mandatory],

        [:last_transition_at, :time, :mandatory],
        [:last_transition_to_state, :string, :mandatory],
        [:last_message_at, :time, :optional],
        [:last_message_content, :string, :optional],

        [:sum_cents, :fixnum, :optional],
        [:currency, :string, :optional],

        [:author, :hash, :mandatory],
        [:waiting_feedback, :mandatory, transform_with: @tiny_int_to_bool],
        [:transitions, :mandatory] # Could add Array validation
      ]

      InboxConvesation = EntityUtils.define_builder(*common_spec, *conversation_spec, *conversation_spec)
      InboxTransaction = EntityUtils.define_builder(*common_spec, *conversation_spec, *transaction_spec)

      module_function

      def query_notification_count(person_id, community_id)
        connection = ActiveRecord::Base.connection
        sql = SQLUtils.ar_quote(connection, @construct_notification_count_sql,
          person_id: person_id,
          community_id: community_id
        )

        connection.select_value(sql)
      end

      def query_inbox_data(person_id, community_id, limit, offset)
        connection = ActiveRecord::Base.connection
        sql = SQLUtils.ar_quote(connection, @construct_sql,
          person_id: person_id,
          community_id: community_id,
          limit: limit,
          offset: offset
        )

        result_set = connection.execute(sql).each(as: :hash).map { |row| HashUtils.symbolize_keys(row) }

        people_ids = HashUtils.pluck(result_set, :current_id, :other_id).uniq
        people_store = MarketplaceService::Person::Query.people(people_ids)

        last_message_conv_ids, last_transition_transaction_ids = reduce_transaction_and_conv_ids(result_set)
        message_store = MarketplaceService::Conversation::Query.latest_messages_for_conversations(last_message_conv_ids)
        transition_store = MarketplaceService::Transaction::Query.latest_transition_for_transaction(last_transition_transaction_ids)

        result_set.map do |result|
          if result[:transaction_id].present?
            InboxTransaction[
              extend_transaction(
                extend_common(result, people_store, message_store),
                transition_store
              )
            ]
          else
            InboxConvesation[
              extend_conversation(
                extend_common(result, people_store, message_store)
              )
            ]
          end
        end
      end

      def reduce_transaction_and_conv_ids(result_set)
        result_set.reduce([[],[]]) { |(last_message_memo, last_transition_memo), row|
          if row[:last_message_at].nil?
            last_transition_memo << row[:transaction_id]
          elsif row[:last_transition_at].nil?
            last_message_memo << row[:conversation_id]
          elsif (row[:last_message_at] > row[:last_transition_at])
            last_message_memo << row[:conversation_id]
          else
            last_transition_memo << row[:transaction_id]
          end
          [last_message_memo, last_transition_memo]
        }
      end

      def query_inbox_data_count(person_id, community_id)
        connection = ActiveRecord::Base.connection
        sql = SQLUtils.ar_quote(connection, @construct_count_sql,
          person_id: person_id,
          community_id: community_id
        )

        connection.select_value(sql)
      end

      def extend_common(common, people, message_store)
        current_id = common[:current_id]
        other_id   = common[:other_id]
        starter_id = common[:current_is_starter] ? common[:current_id] : common[:other_id]

        content, message_at = message_store[common[:conversation_id]]

        common.merge(
          starter: people[starter_id],
          other: people[other_id],
          current: people[current_id],
          last_message_content: content,
          last_message_at: message_at
        )
      end

      def extend_conversation(conversation)
        conversation.merge(
          should_notify: !@tiny_int_to_bool.call(conversation[:current_is_read])
        )
      end

      def extend_transaction(transaction, transition_store)
        transitions = TransactionTransition.where(transaction_id: transaction[:transaction_id]).map do |transition_model|
          MarketplaceService::Transaction::Entity::Transition[EntityUtils.model_to_hash(transition_model)]
        end

        transition_to, transition_at = transition_store[transaction[:transaction_id]]

        should_notify =
          !@tiny_int_to_bool.call(transaction[:current_is_read]) ||
          @tiny_int_to_bool.call(transaction[:current_action_required]) ||
          @tiny_int_to_bool.call(transaction[:waiting_feedback])

        transaction.merge(
          author: transaction[:other],
          transitions: transitions,
          should_notify: should_notify,
          last_transition_to_state: transition_to,
          last_transition_at: transition_at
        )
      end

      @construct_notification_count_sql = ->(params) {
        "
          SELECT COUNT(conversations.id) FROM conversations

          LEFT JOIN transactions      ON transactions.conversation_id = conversations.id
          LEFT JOIN listings          ON transactions.listing_id = listings.id
          LEFT JOIN testimonials      ON (testimonials.transaction_id = transactions.id AND testimonials.author_id = #{params[:person_id]})
          LEFT JOIN participations    ON (participations.conversation_id = conversations.id AND participations.person_id = #{params[:person_id]})

          # Where person and community
          WHERE conversations.community_id = #{params[:community_id]}
          AND (participations.person_id = #{params[:person_id]})

          # This is a bit complicated logic that is now moved from app to SQL.
          # I'm not complelety sure if it's a good or bad. However, since this query is called once per every page
          # load, I think it's ok to make some performance optimizations and have this logic in SQL.
          AND (
            # Is read?
            (participations.is_read = FALSE) OR

            # Requires actions
            ((transactions.current_state = 'pending' OR transactions.current_state = 'preauthorized') AND participations.is_starter = FALSE) OR
            ((transactions.current_state = 'accepted' OR transactions.current_state = 'paid')         AND participations.is_starter = TRUE) OR

            # Waiting feedback
            ((transactions.current_state = 'confirmed') AND (
              (participations.is_starter = TRUE AND transactions.starter_skipped_feedback = FALSE AND testimonials.id IS NULL) OR
              (participations.is_starter = FALSE AND transactions.author_skipped_feedback = FALSE AND testimonials.id IS NULL)
            ))
          )
        "
      }

      # Construct query for
      # - person
      # - community
      # - sorted by last acticity
      # - with pagination
      @construct_sql = ->(params) {
        "
          SELECT
            transactions.id AS transaction_id,
            conversations.id AS conversation_id,

            GREATEST(COALESCE(transactions.last_transition_at, 0),
              COALESCE(conversations.last_message_at, 0))     AS last_activity_at,

            transactions.last_transition_at                   AS last_transition_at,
            conversations.last_message_at                     AS last_message_at,

            listings.id                                       AS listing_id,
            listings.title                                    AS listing_title,

            payments.sum_cents                                AS sum_cents,
            payments.currency                                 AS currency,

            listings.author_id                                AS author_id,
            current_participation.person_id                   AS current_id,
            other_participation.person_id                     AS other_id,

            transaction_types.type                            AS transaction_type,

            current_participation.is_read                     AS current_is_read,
            current_participation.is_starter                  AS current_is_starter,

            # Requires actions
            (
             ((transactions.current_state = 'pending' OR transactions.current_state = 'preauthorized') AND current_participation.is_starter = FALSE) OR
             ((transactions.current_state = 'accepted' OR transactions.current_state = 'paid')         AND current_participation.is_starter = TRUE)
            )                                                 AS current_action_required,

            # Waiting feedback
            ((transactions.current_state = 'confirmed') AND (
             (current_participation.is_starter = TRUE AND transactions.starter_skipped_feedback = FALSE AND testimonials.id IS NULL) OR
             (current_participation.is_starter = FALSE AND transactions.author_skipped_feedback = FALSE AND testimonials.id IS NULL)
            ))                                                AS waiting_feedback
          FROM conversations

          LEFT JOIN transactions      ON transactions.conversation_id = conversations.id
          LEFT JOIN listings          ON transactions.listing_id = listings.id
          LEFT JOIN transaction_types ON listings.transaction_type_id = transaction_types.id
          LEFT JOIN payments          ON payments.transaction_id = transactions.id
          LEFT JOIN testimonials      ON (testimonials.transaction_id = transactions.id AND testimonials.author_id = #{params[:person_id]})
          LEFT JOIN participations    AS current_participation ON (current_participation.conversation_id = conversations.id AND current_participation.person_id = #{params[:person_id]})
          LEFT JOIN participations    AS other_participation ON (other_participation.conversation_id = conversations.id AND other_participation.person_id != #{params[:person_id]})

          # Where person and community
          WHERE conversations.community_id = #{params[:community_id]}
          AND ((current_participation.person_id = #{params[:person_id]}) OR (other_participation.person_id = #{params[:person_id]}))

          # Order by 'last_activity_at', that is last message or last transition
          ORDER BY last_activity_at DESC

          # Pagination
          LIMIT #{params[:limit]} OFFSET #{params[:offset]}
        "
      }

      @construct_count_sql = ->(params) {
        "
          SELECT COUNT(conversations.id)
          FROM conversations

          LEFT JOIN participations    AS current_participation ON (current_participation.conversation_id = conversations.id AND current_participation.person_id = #{params[:person_id]})
          LEFT JOIN participations    AS other_participation ON (other_participation.conversation_id = conversations.id AND other_participation.person_id != #{params[:person_id]})

          # Where person and community
          WHERE conversations.community_id = #{params[:community_id]}
          AND ((current_participation.person_id = #{params[:person_id]}) OR (other_participation.person_id = #{params[:person_id]}))
        "
      }
    end
  end
end
