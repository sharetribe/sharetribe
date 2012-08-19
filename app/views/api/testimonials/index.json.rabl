object false

child @testimonials => "feedbacks" do
  extends "api/testimonials/show"
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

node :grade_amounts do |listings|
  @grade_amounts
end
