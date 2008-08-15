class Session < ActiveResource::Base
 
  self.site = "http://maps.cs.hut.fi/cos"
  self.element_name = "session"
  self.collection_name = "session" #exceptionally not plural, bacause COS requires "session"
  self.format = :json 
  class << self
    def element_path(id, prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      # path to the resource, which we want to access is evaluated in this statement: 
      "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
    end

    def collection_path(prefix_options = {}, query_options = nil)
      #puts prefix_options.inspect + "LASDFOIHASFGIOAUBHAEGAHDSIGU"
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}#{simplify_parameters(query_string(query_options))}?app_name=kassi&app_password=Xk4z5iZ"
    end
    def simplify_parameters(params)
       puts params
       puts "DEBUG!"
       params
     end
  end

  def create
    resp = connection.post("#{self.class.prefix}#{self.class.element_name}?app_name=kassi&app_password=Xk4z5iZ") 
    self.class.headers["Cookie"] = resp.get_fields("set-cookie").to_s
  end
  
  def get(path, headers = {})
      resp = connection.get("#{self.class.prefix}#{self.class.element_name}", self.class.headers)
  end
   
  def destroy
    resp = connection.delete("#{self.class.prefix}#{self.class.element_name}", self.class.headers)
  end

  
 
end
