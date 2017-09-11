require 'csv'

class Admin::CommunityTransactionsController < Admin::AdminBaseController

  def index
    @selected_left_navi_link = "transactions"
    transactions, last_activity = load_transactions

    respond_to do |format|
      format.html do
        render("index", {
          locals: {
            community: @current_community,
            transactions: transactions,
            last_activity: last_activity
          }
        })
      end
      FeatureFlagHelper.with_feature(:export_transactions_as_csv) do
        format.csv do
          marketplace_name = if @current_community.use_domain
            @current_community.domain
          else
            @current_community.ident
          end

          self.response.headers["Content-Type"] ||= 'text/csv'
          self.response.headers["Content-Disposition"] = "attachment; filename=#{marketplace_name}-transactions-#{Date.today}.csv"
          self.response.headers["Content-Transfer-Encoding"] = "binary"
          self.response.headers["Last-Modified"] = Time.now.ctime.to_s

          self.response_body = Enumerator.new do |yielder|
            generate_csv_for(yielder, transactions, last_activity)
          end
        end
      end
    end
  end

  def generate_csv_for(yielder, transactions, last_activity)
    # first line is column names
    yielder << %w{
      transaction_id
      listing_id
      listing_title
      status
      currency
      sum
      started_at
      last_activity_at
      starter_username
      other_party_username
    }.to_csv(force_quotes: true)
    transactions.each do |transaction|
      yielder << [
        transaction.id,
        transaction.listing ? transaction.listing.id : "N/A",
        transaction.listing_title || "N/A",
        transaction.status,
        transaction.payment_total.is_a?(Money) ? transaction.payment_total.currency : "N/A",
        transaction.payment_total,
        transaction.created_at,
        last_activity[transaction.id],
        transaction.starter ? transaction.starter.username : "DELETED",
        transaction.author ? transaction.author.username : "DELETED"
      ].to_csv(force_quotes: true)
    end
  end

  private

  def load_transactions
    pagination_opts = PaginationViewUtils.parse_pagination_opts(params)

    transactions = if params[:sort].nil? || params[:sort] == "last_activity"
      transactions_for_community_sorted_by_activity(
        @current_community.id,
        sort_direction,
        pagination_opts[:limit],
        pagination_opts[:offset])
    else
      transactions_for_community_sorted_by_column(
        @current_community.id,
        simple_sort_column(params[:sort]),
        sort_direction,
        pagination_opts[:limit],
        pagination_opts[:offset])
    end

    count = @current_community.transactions.not_deleted.count
    last_activity_map = {}
    transactions.each do |tx|
      last_activity_map[tx.id] = last_activity_for(tx)
    end

    transactions = WillPaginate::Collection.create(pagination_opts[:page], pagination_opts[:per_page], count) do |pager|
      pager.replace(transactions)
    end
    [transactions, last_activity_map]
  end

  def last_activity_for(transaction)
    if !transaction.conversation || transaction.conversation.last_message_at.nil?
      transaction.last_transition_at
    elsif transaction.last_transition_at.nil?
      transaction.conversation.last_message_at
    else
      [transaction.last_transition_at, transaction.conversation.last_message_at].max
    end
  end

  def simple_sort_column(sort_column)
    case sort_column
    when "listing"
      "listings.title"
    when "started"
      "created_at"
    end
  end

  def sort_direction
    params[:direction] || "desc"
  end

  def transactions_for_community_sorted_by_column(community_id, sort_column, sort_direction, limit, offset)
    Transaction
      .where(community_id: community_id, deleted: false)
      .includes(:listing)
      .limit(limit)
      .offset(offset)
      .order("#{sort_column} #{sort_direction}")
  end

  def transactions_for_community_sorted_by_activity(community_id, sort_direction, limit, offset)
    sql = sql_for_transactions_for_community_sorted_by_activity(community_id, sort_direction, limit, offset)
    transactions = Transaction.find_by_sql(sql)
  end

  def sql_for_transactions_for_community_sorted_by_activity(community_id, sort_direction, limit, offset)
    "
      SELECT transactions.* FROM transactions

      # Get 'last_transition_at'
      # (this is done by joining the transitions table to itself where created_at < created_at OR sort_key < sort_key, if created_at equals)
      LEFT JOIN conversations ON transactions.conversation_id = conversations.id
      WHERE transactions.community_id = #{community_id} AND transactions.deleted = 0
      ORDER BY
        GREATEST(COALESCE(transactions.last_transition_at, 0),
          COALESCE(conversations.last_message_at, 0)) #{sort_direction}
      LIMIT #{limit} OFFSET #{offset}
    "
  end

end
