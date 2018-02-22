require 'csv'
class ExportTransactionsJob < Struct.new(:current_user_id, :community_id, :export_task_id)
  TransactionQuery = MarketplaceService::Transaction::Query
  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    community = Community.find(community_id)
    user = Person.find(current_user_id)
    export_task = ExportTaskResult.find(export_task_id)
    export_task.update_attributes(status: 'started')

    conversations = TransactionQuery.transactions_for_community_sorted_by_activity(community.id, 'desc', nil, nil, true)
    conversations = conversations.map do |transaction|
      conversation = transaction[:conversation]
      author = Maybe(conversation[:other_person]).or_else({is_deleted: true})
      starter = Maybe(conversation[:starter_person]).or_else({is_deleted: true})
      transaction[:last_activity_at] = ExportTransactionsJob.last_activity_for(transaction)

      transaction.merge({author: author, starter: starter})
    end


    csv_rows = []
    ExportTransactionsJob.generate_csv_for(csv_rows, conversations)
    csv_content = csv_rows.join("")
    marketplace_name = community.use_domain ? community.domain : community.ident
    filename = "#{marketplace_name}-transactions-#{Time.zone.today}-#{export_task.token}.csv"
    export_task.original_filename = filename
    export_task.original_extname = File.extname(filename).delete('.')
    export_task.update_attributes(status: 'finished', file: FakeFileIO.new(filename, csv_content))
  end

  class FakeFileIO < StringIO
    attr_reader :original_filename
    attr_reader :path

    def initialize(filename, content)
      super(content)
      @original_filename = File.basename(filename)
      @path = File.path(filename)
    end
  end

  def self.generate_csv_for(yielder, conversations)
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
    conversations.each do |conversation|
      yielder << [
        conversation[:id],
        conversation[:listing] ? conversation[:listing][:id] : "N/A",
        conversation[:listing_title] || "N/A",
        conversation[:status],
        conversation[:payment_total].is_a?(Money) ? conversation[:payment_total].currency : "N/A",
        conversation[:payment_total],
        conversation[:created_at],
        conversation[:last_activity_at],
        conversation[:starter] ? conversation[:starter][:username] : "DELETED",
        conversation[:author] ? conversation[:author][:username] : "DELETED"
      ].to_csv(force_quotes: true)
    end
  end

  def self.last_activity_for(conversation)
    last_activity_at = 0
    last_activity_at = if conversation[:conversation][:last_message_at].nil?
      conversation[:last_transition_at]
    elsif conversation[:last_transition_at].nil?
      conversation[:conversation][:last_message_at]
    else
      [conversation[:last_transition_at], conversation[:conversation][:last_message_at]].max
    end
    last_activity_at
  end

end
