require 'spec_helper'

describe BraintreeAccountsController, type: :controller do
  describe "#create" do
    before(:each) do
      @community = FactoryGirl.create(:community)
      FactoryGirl.create(:braintree_payment_gateway, :community => @community)

      @request.host = "#{@community.ident}.lvh.me"
      @request.env[:current_marketplace] = @community
      @person = FactoryGirl.create(:person)
      @community.members << @person
      sign_in_for_spec(@person)
    end

    it "should create braintree details with detailed information" do
      # Mock BraintreeApi
      expect(BraintreeApi).to receive(:create_merchant_account)
        .and_return(Braintree::SuccessfulResult.new(:merchant_account => HashClass.new(:status => "pending")))

      post :create, :braintree_account => {
        :person_id => @person.id,
        :first_name => "Joe",
        :last_name => "Bloggs",
        :email => "joe@14ladders.com",
        :phone => "5551112222",
        :address_street_address => "123 Credibility St.",
        :address_postal_code => "60606",
        :address_locality => "Chicago",
        :address_region => "IL",
        :"date_of_birth(1i)" => "1980",
        :"date_of_birth(2i)" => "10",
        :"date_of_birth(3i)" => "09",
        :routing_number => "101000187",
        :account_number => "43759348798"
      }, person_id: @person.id

      braintree_account = BraintreeAccount.find_by_person_id(@person.id)
      expect(braintree_account.first_name).to be_eql("Joe")
      expect(braintree_account.last_name).to be_eql("Bloggs")
      expect(braintree_account.email).to be_eql("joe@14ladders.com")
      expect(braintree_account.phone).to be_eql("5551112222")
      expect(braintree_account.address_street_address).to be_eql("123 Credibility St.")
      expect(braintree_account.address_postal_code).to be_eql("60606")
      expect(braintree_account.address_locality).to be_eql("Chicago")
      expect(braintree_account.address_region).to be_eql("IL")
      expect(braintree_account.date_of_birth.year).to be_eql(1980)
      expect(braintree_account.date_of_birth.month).to be_eql(10)
      expect(braintree_account.date_of_birth.day).to be_eql(9)
      expect(braintree_account.routing_number).to be_eql("101000187")
      expect(braintree_account.hidden_account_number).to be_eql("*********98")
      expect(braintree_account.community_id).to eq(@community.id)
    end

    it "should not create braintree account with missing information" do
      # Mock BraintreeApi
      expect(BraintreeApi).not_to receive(:create_merchant_account)

      post :create, :braintree_account => {:person_id => @person.id, :first_name => "Joe", :last_name => "Bloggs"}, person_id: @person.id
      expect(BraintreeAccount.find_by_person_id(@person.id)).to be_nil
    end
  end
end
