object false

child @listings => "listings" do
  extends "api/listings/show"
end

node :page do |listings|
  @page
end

node :per_page do |listings|
  @per_page
end

node :total_pages do |listings|
  @total_pages
end
