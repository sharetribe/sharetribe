module Result

  Success = Struct.new(
    :success, # Boolean
    :data # Additional response data
  ) do

    def initialize(data = nil)
      self.success = true
      self.data = data
    end
  end

  Error = Struct.new(
    :success,
    :error_msg,
    :data
  ) do

    def initialize(error_msg, data = nil)
      self.success = false
      self.error_msg = error_msg
      self.data = data
    end
  end

end
