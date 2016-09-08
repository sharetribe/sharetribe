module ServiceClient
  class Client
    def initialize(endpoints, middleware)
      @_endpoints = endpoints
      @_middleware = middleware || []
    end

    def get(endpoint, params = {}, opts = {})
    end

    def post(endpoint, params = {}, opts = {})
    end
  end
end
