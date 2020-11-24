describe PaypalService::Store::ProcessToken do

  ProcessTokenStore = PaypalService::Store::ProcessToken

  CID = 10
  PAYPAL_TOKEN = "paypal_token"
  TX_ID = 1001

  context "#create" do

    it "saves a new token with given info and generated process_token uuid" do
      proc_token = ProcessTokenStore.create(
        community_id: CID,
        transaction_id: TX_ID,
        op_name: :create)
      proc_token = ProcessTokenStore.get_by_process_token(proc_token[:process_token])

      expect(proc_token[:community_id]).to eq(CID)
      expect(proc_token[:transaction_id]).to eq(TX_ID)
      expect(proc_token[:op_completed]).to be_falsey
    end

    it "prevents creating token for same community id, transaction id and op_name twice" do
      proc_token = ProcessTokenStore.create(
        community_id: CID,
        transaction_id: TX_ID,
        op_name: :request)
      proc_token2 = ProcessTokenStore.create(
        community_id: CID,
        transaction_id: TX_ID,
        op_name: :request)

      expect(proc_token).not_to be_nil
      expect(proc_token2).to be_nil
    end

    it "uniqueness is a combination of community id, transaction id and op_name" do
      ProcessTokenStore.create(community_id: CID, transaction_id: TX_ID, op_name: :request)
      different_com = ProcessTokenStore.create(community_id: CID + 1, transaction_id: TX_ID, op_name: :request)
      different_tx = ProcessTokenStore.create(community_id: CID, transaction_id: TX_ID + 1, op_name: :request)
      different_op_name = ProcessTokenStore.create(community_id: CID, transaction_id: TX_ID, op_name: :create)

      expect(different_com).not_to be_nil
      expect(different_tx).not_to be_nil
      expect(different_op_name).not_to be_nil
    end

    it "serializes op_input" do
      op_input = [CID, { community_id: CID, item_name: "Item name", now: Time.now, order_total: Money.new(14500, "USD")}]

      proc_token = ProcessTokenStore.create(
        community_id: CID,
        transaction_id: TX_ID,
        op_name: :request,
        op_input: op_input)
      proc_token = ProcessTokenStore.get_by_process_token(proc_token[:process_token])

      expect(proc_token[:op_input]).to eq(op_input)
    end

    it "can be queried by community_id, transaction_id and op_name" do
      proc_token = ProcessTokenStore.create(
        community_id: CID,
        transaction_id: TX_ID,
        op_name: :create)
      proc_token_by_id = ProcessTokenStore.get_by_process_token(proc_token[:process_token])
      proc_token_by_tx = ProcessTokenStore.get_by_transaction(community_id: CID, transaction_id: TX_ID, op_name: :create)

      expect(proc_token_by_tx).to eq(proc_token_by_id)
    end
  end

  context "#update_to_completed" do

    before(:each) do
      @proc_token = ProcessTokenStore.create(
        community_id: CID,
        transaction_id: TX_ID,
        op_name: :create)
    end

    it "sets op_completed" do
      ProcessTokenStore.update_to_completed(
        process_token: @proc_token[:process_token],
        op_output: {})

      proc_token = ProcessTokenStore.get_by_process_token(@proc_token[:process_token])
      expect(proc_token[:op_completed]).to be_truthy
    end

    it "serializes op_output" do
      op_output = Result::Success.new({ community_id: 10, order_total: Money.new(2500, "EUR"), order_date: Time.now} )
      ProcessTokenStore.update_to_completed(
        process_token: @proc_token[:process_token],
        op_output: op_output)

      proc_token = ProcessTokenStore.get_by_process_token(@proc_token[:process_token])
      expect(proc_token[:op_output]).to eq(op_output)
    end

    it "raises error if called for non-existent process token" do
      expect {
        ProcessTokenStore.update_to_completed(
          process_token: "not-a-real-process-token",
          op_output: {})
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

  end
end
