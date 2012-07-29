object false

child @conversations => "conversations" do
  attributes :id, :title, :status, :listing_id, :created_at, :updated_at
  child :participations do
    attributes :is_read, :last_sent_at, :last_received_at, :feedback_skipped
    child :person do 
      extends "api/people/small_info"
    end
  end
end

node :page do |conversations|
  @page
end

node :per_page do |conversations|
  @per_page
end

node :total_pages do |conversations|
  @total_pages
end
