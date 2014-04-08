describe Admin::SortingService do

  describe "#next_sort_priority" do

    it "returns next int" do
      categories = [
        FactoryGirl.create(:category, sort_priority: 0),
        FactoryGirl.create(:category, sort_priority: 4)
      ]

      Admin::SortingService.next_sort_priority(categories).should == 5
    end

    it "handles nils" do
      categories = [
        FactoryGirl.create(:category, sort_priority: 2),
        FactoryGirl.create(:category, sort_priority: nil),
        FactoryGirl.create(:category, sort_priority: 8)
      ]

      Admin::SortingService.next_sort_priority(categories).should == 9
    end

    it "handles empty array" do
      Admin::SortingService.next_sort_priority([]).should == 1
    end

  end
end
