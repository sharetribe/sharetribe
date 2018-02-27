require 'csv'
class ExportTransactionsJob < Struct.new(:current_user_id, :community_id, :export_task_id)
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
    export_task = ExportTaskResult.find(export_task_id)
    export_task.update_attributes(status: 'started')

    conversations = Transaction.for_community_sorted_by_activity(community.id, 'desc', nil, nil, true)
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

  class << self
    def generate_csv_for(yielder, transactions)
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
         transaction.last_activity,
         transaction.starter ? transaction.starter.username : "DELETED",
         transaction.author ? transaction.author.username : "DELETED"
       ].to_csv(force_quotes: true)
     end
    end
  end
end
