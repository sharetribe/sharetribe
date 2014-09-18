module PaypalService
  module PaypalAction

    module_function

    ActionDef = EntityUtils.define_builder(
      [:input_transformer, :mandatory, :callable],
      [:wrapper_method_name, :mandatory, :symbol],
      [:action_method_name, :mandatory, :symbol],
      [:output_transformer, :mandatory, :callable])

    def def_action(opts)
      ActionDef.call(opts)
    end

  end
end
