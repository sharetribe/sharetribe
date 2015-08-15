describe TransactionService::Process do
  let(:process) { TransactionService::API::Process.new }

  describe "#get and #create" do
    it "returns with single process" do
      id_1 = process.create(community_id: 111, process: :none, author_is_seller: false).data[:id]
      id_2 = process.create(community_id: 222, process: :preauthorize, author_is_seller: true).data[:id]

      expect(process.get(community_id: 111, process_id: id_1).data).to eql({community_id: 111, id: id_1, process: :none, author_is_seller: false})
      expect(process.get(community_id: 222, process_id: id_2).data).to eql({community_id: 222, id: id_2, process: :preauthorize, author_is_seller: true})
    end

    it "returns error if specified process not found" do
      id_1 = process.create(community_id: 111, process: :none, author_is_seller: false).data[:id]
      id_2 = process.create(community_id: 222, process: :preauthorize, author_is_seller: true).data[:id]

      expect(process.get(community_id: 222, process_id: id_1).success).to eql(false)
      expect(process.get(community_id: 111, process_id: id_2).success).to eql(false)
    end

    it "returns with all community processes" do
      id_1 = process.create(community_id: 111, process: :none, author_is_seller: false).data[:id]
      id_2 = process.create(community_id: 111, process: :preauthorize, author_is_seller: true).data[:id]
      id_3 = process.create(community_id: 222, process: :postpay, author_is_seller: true).data[:id]

      expect(process.get(community_id: 111).data)
        .to eql([{community_id: 111, id: id_1, process: :none, author_is_seller: false},
                    {community_id: 111, id: id_2, process: :preauthorize, author_is_seller: true}])

      expect(process.get(community_id: 222).data)
        .to eql([{community_id: 222, id: id_3, process: :postpay, author_is_seller: true}])

      expect(process.get(community_id: 333).data).to eql([])
    end
  end
end
