module TransactionService::Gateway

  # Wrap response to signal that the gateway adapter has synchronously
  # completed its work. Process can directly continue with next
  # actions and state transitions.
  SyncCompletion = Struct.new(:success, :response, :sync) do
    def initialize(result)
      self.success = result.success
      self.response = result
      self.sync = true
    end
  end

  # Wrap response to signal that the gateway adapter operation is
  # asynchronous and completion will be later signaled via a
  # listenable event. The process should wait for the event before
  # continuing.
  AsyncCompletion = Struct.new(:success, :response, :sync) do
    def initialize(result)
      self.success = result.success
      self.response = result
      self.sync = false
    end
  end


  module_function

  def unwrap_completion(completion, &sync_success_cb)
    response = completion[:response]

    if response[:success] && completion[:sync]
      sync_success_cb.call(response)
    end

    response
  end

end
