object false

child @people => "people" do
  extends "api/people/small_info"
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
