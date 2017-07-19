module TransactionService::API
  class Settings

    PaymentSettingsStore = TransactionService::Store::PaymentSettings

    # Provision new settings (= new gateway and/or process) for a community
    def provision(settings)
      existing_settings = PaymentSettingsStore.get(settings.slice(:community_id, :payment_gateway, :payment_process))
      unless existing_settings.nil?
        return Result::Error.new("gateway / process already provisioned. cid: #{settings[:community_id]}, gateway: #{settings[:payment_gateway]}, process: #{settings[:payment_process]}")
      end

      Result::Success.new(PaymentSettingsStore.create(settings))
    end

    def get(community_id:, payment_gateway:, payment_process:)
      Result::Success.new(PaymentSettingsStore.get(
                           community_id: community_id,
                           payment_gateway: payment_gateway,
                           payment_process: payment_process))
    end

    # Update settings but don't change gateway, process or active state
    def update(settings)
      Result::Success.new(PaymentSettingsStore.update(settings))
    end

    def get_active_by_gateway(community_id:, payment_gateway:)
      Result::Success.new(PaymentSettingsStore.get_active_by_gateway(community_id: community_id, payment_gateway: payment_gateway))
    end

    # Update the given gateway and process to be the active one, disable others
    def activate(community_id:, payment_gateway:, payment_process:)
      Result::Success.new(PaymentSettingsStore.activate(
                           community_id: community_id,
                           payment_gateway: payment_gateway,
                           payment_process: payment_process))
    end

    def disable(community_id:, payment_gateway:, payment_process:)
      Result::Success.new(PaymentSettingsStore.disable(
                           community_id: community_id,
                           payment_gateway: payment_gateway,
                           payment_process: payment_process))
    end

    def api_verified(community_id:, payment_gateway:, payment_process:)
      Result::Success.new(PaymentSettingsStore.api_verified(
                           community_id: community_id,
                           payment_gateway: payment_gateway,
                           payment_process: payment_process))
    end


  end
end
