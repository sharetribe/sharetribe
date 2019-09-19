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
    export_task.update(status: 'started')

    conversations = Transaction.for_community_sorted_by_activity(community.id, 'desc', true)
    csv_rows = []
    ExportTransactionsJob.generate_csv_for(csv_rows, conversations)
    csv_content = csv_rows.join("")
    marketplace_name = community.use_domain ? community.domain : community.ident
    filename = "#{marketplace_name}-transactions-#{Time.zone.today}-#{export_task.token}.csv"
    export_task.original_filename = filename
    export_task.original_extname = File.extname(filename).delete('.')
    export_task.update(status: 'finished', file: FakeFileIO.new(filename, csv_content))
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
       commission_from_provider
       commission_from_buyer
       started_at
       last_activity_at
       buyer_user_id
       provider_user_id
     }.to_csv(force_quotes: true)
     transactions.each do |transaction|
       yielder << [
         transaction.id,
         transaction.listing ? transaction.listing.id : "N/A",
         transaction.listing_title || "N/A",
         transaction.status,
         transaction.payment_total.is_a?(Money) ? transaction.payment_total.currency : "N/A",
         transaction.payment_total,
         transaction.commission,
         transaction.buyer_commission,
         transaction.created_at && I18n.l(transaction.created_at, format: '%Y-%m-%d %H:%M:%S'),
         transaction.last_activity && I18n.l(transaction.last_activity, format: '%Y-%m-%d %H:%M:%S'),
         transaction.starter ? transaction.starter.id : "DELETED",
         transaction.author ? transaction.author.id : "DELETED"
       ].to_csv(force_quotes: true)
     end
    end
  end
end
