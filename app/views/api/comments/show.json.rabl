object @comment
attributes :content, :created_at

child :author => :author do 
  extends "api/people/small_info"
end