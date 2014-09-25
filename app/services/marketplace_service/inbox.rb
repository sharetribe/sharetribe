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

    end

    module Command

    end

    module Query
      PersonModel = ::Person

      conversation_fields = [
        [:title, :string, :mandatory],
        [:last_update_at, :string, :mandatory],
        [:path, :string, :mandatory],
        [:other_party, :hash, :mandatory],
        [:is_read, :bool, :mandatory]
      ]

      transasction_fields = [
        [:listing_title, :string, :mandatory],
        [:listing_url, :string, :mandatory],
        [:is_author, :bool, :mandatory],
        [:waiting_feedback_from_current, :mandatory],
        [:transaction_status, :string, :mandatory]
      ]

      InboxRowConversation = EntityUtils.define_builder(*conversation_fields)
      InboxRowTransaction = EntityUtils.define_builder(*conversation_fields, *transasction_fields)

      module_function

      def inbox_data(person_id, community_id, limit, offset)
        Rails.logger.info("*************************** INBOX DATA START ***************************")
        TimingService.log(0, "*************************** INBOX DATA ***************************") do
          sql = sql_for_conversations_for_community_sorted_by_activity(person_id, community_id, limit, offset)

          ActiveRecord::Base.connection.execute(sql).each(as: :hash).map do |result_hash|

            starter = MarketplaceService::Person::Entity.person(PersonModel.find(result_hash["starter_id"]))
            other = MarketplaceService::Person::Entity.person(PersonModel.find(result_hash["other_id"]))

            message_was_last = if result_hash["last_transition_at"].nil?
              true
            elsif result_hash["last_message_at"].nil?
              false
            elsif result_hash["last_transition_to_state"] != "free" && result_hash["last_transition_to_state"] != "pending"
              result_hash["last_message_at"] > result_hash["last_transition_at"]
            else
              true
            end

            title = if message_was_last
              result_hash["last_message_content"]
            else
              transitions = TransactionTransition.where(transaction_id: result_hash["transaction_id"]).map do |transition_model|
                MarketplaceService::Transaction::Entity::Transition[EntityUtils.model_to_hash(transition_model)]
              end
              discussion_type = Entity.discussion_type(result_hash["transaction_type"])
              payment_sum = Money.new(result_hash["sum_cents"], result_hash["currency"])
              TransactionViewUtils.create_messages_from_actions(transitions, discussion_type, other, starter, payment_sum).last[:content]
            end

            is_read = if result_hash["starter_id"] == person_id
              result_hash["starter_is_read"]
            else
              result_hash["other_is_read"]
            end

            current_is_author =

            conversation = InboxRowConversation[{
              title: title,
              last_update_at: result_hash["last_activity_at"],
              other_party: starter[:id] == person_id ? other : starter,
              is_read: is_read,
              path: result_hash["conversation_id"].to_s
            }]

            if result_hash["listing_id"]
              InboxRowTransaction[conversation.merge({
                path: result_hash["transaction_id"].to_s,
                listing_title: result_hash["listing_title"],
                is_author: result_hash["starter_id"] != person_id,
                waiting_feedback_from_current: result_hash["current_user_testimonial_id"].nil?,
                transaction_status: result_hash["last_transition_to_state"],
                listing_url: result_hash["listing_id"].to_s
              })]
            else
              conversation
            end
          end
        end
      end

      def sql_for_conversations_for_community_sorted_by_activity(person_id, community_id, limit, offset)
        "
          SELECT
            transactions.id as transaction_id,
            conversations.id as conversation_id,
            m.last_message_at,
            m.last_message_content,
            tt.last_transition_at,
            tt.last_transition_to_state,
            GREATEST(COALESCE(tt.last_transition_at, 0), COALESCE(m.last_message_at, 0)) as last_activity_at,
            listings.id as listing_id,
            listings.title as listing_title,
            listings.author_id as author_id,
            payments.sum_cents as sum_cents,
            payments.currency as currency,
            transaction_types.type as transaction_type,
            transactions.author_skipped_feedback as author_skipped_feedback,
            transactions.starter_skipped_feedback as starter_skipped_feedback,
            starter_participation.person_id as starter_id,
            starter_participation.is_read as starter_is_read,
            other_participation.person_id as other_id,
            other_participation.is_read as other_is_read,
            testimonials.id as current_user_testimonial_id
          FROM conversations

          # Join transactions and participations
          LEFT JOIN transactions ON transactions.conversation_id = conversations.id

          # Join listing
          LEFT JOIN listings ON transactions.listing_id = listings.id

          # Join transaction type
          LEFT JOIN transaction_types ON listings.transaction_type_id = transaction_types.id

          # Join payment
          LEFT JOIN payments ON payments.transaction_id = transactions.id

          # Join testimonial from current
          LEFT JOIN testimonials ON (testimonials.transaction_id = transactions.id AND testimonials.author_id = '#{person_id}')


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

          LEFT JOIN participations AS starter_participation ON starter_participation.conversation_id = conversations.id AND starter_participation.is_starter = true
          LEFT JOIN participations AS other_participation ON other_participation.conversation_id = conversations.id AND other_participation.is_starter = false

          # Where person and community
          WHERE conversations.community_id = #{community_id}
          AND (starter_participation.person_id = '#{person_id}') OR (other_participation.person_id = '#{person_id}')

          # Order by 'last_activity_at', that is last message or last transition
          ORDER BY last_activity_at DESC

          # Pagination
          LIMIT #{limit} OFFSET #{offset}
        "
      end
    end
  end
end
