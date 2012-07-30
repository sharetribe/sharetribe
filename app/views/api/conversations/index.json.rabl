object false

child @conversations => "conversations" do
  extends "api/conversations/latest_message_only"
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
