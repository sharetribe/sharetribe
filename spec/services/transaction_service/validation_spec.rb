require 'spec_helper'

describe TransactionService::Validation::ItemTotal do

  let(:item_total) { TransactionService::Validation::ItemTotal }

  it "calculates the item total" do
    expect(item_total.new(unit_price: Money.new(2500, "USD"), quantity: 10).total)
      .to eq(Money.new(25_000, "USD"))

    expect(item_total.new(unit_price: Money.new(0, "EUR"), quantity: 10).total)
      .to eq(Money.new(0, "EUR"))

    expect(item_total.new(unit_price: Money.new(2500, "USD"), quantity: 0).total)
      .to eq(Money.new(0, "USD"))
  end
end

describe TransactionService::Validation::ShippingTotal do

  let(:shipping_total) { TransactionService::Validation::ShippingTotal }

  it "calculates the shipping total" do
    expect(shipping_total.new(initial: Money.new(5000, "EUR"), additional: 0, quantity: 1).total)
      .to eq(Money.new(5000, "EUR"))

    expect(shipping_total.new(initial: Money.new(5000, "EUR"), additional: 0, quantity: 10).total)
      .to eq(Money.new(5000, "EUR"))

    expect(shipping_total.new(initial: Money.new(5000, "USD"), additional: Money.new(1000, "USD"), quantity: 1).total)
      .to eq(Money.new(5000, "USD"))

    expect(shipping_total.new(initial: Money.new(5000, "USD"), additional: Money.new(1000, "USD"), quantity: 5).total)
      .to eq(Money.new(9000, "USD"))
  end
end

describe TransactionService::Validation::OrderTotal do

  let(:item_total) { TransactionService::Validation::ItemTotal }
  let(:shipping_total) { TransactionService::Validation::ShippingTotal }
  let(:order_total) { TransactionService::Validation::OrderTotal }

  it "calculates the order total (item total + shipping total)" do
    items = item_total.new(unit_price: Money.new(25_000, "EUR"), quantity: 5)
    shipping = shipping_total.new(initial: Money.new(2_000, "EUR"), additional: Money.new(500, "EUR"), quantity: 5)

    expect(order_total.new(item_total: items, shipping_total: shipping).total)
      .to eq(Money.new(129_000, "EUR"))
  end
end

describe TransactionService::Validation::Validator do

  let(:validator) { TransactionService::Validation::Validator }

  describe "#validate_delivery_method" do

    context "valid" do
      it "passes valid delivery method" do
        params = {
          tx_params: {
            delivery: :shipping
          },
          shipping_enabled: true,
          pickup_enabled: true
        }

        expect(validator.validate_delivery_method(params).success).to eq(true)
      end
    end

    context "invalid" do

      it "fails for invalid delivery method" do
        params = {
          tx_params: {
            delivery: :shipping
          },
          shipping_enabled: false,
          pickup_enabled: false
        }

        expect(validator.validate_delivery_method(params).data[:code]).to eq(:delivery_method_missing)
      end

      it "fails if delivery method is missing" do

        params = {
          tx_params: {
            delivery: nil
          },
          shipping_enabled: true,
          pickup_enabled: true
        }

        expect(validator.validate_delivery_method(params).data[:code]).to eq(:delivery_method_missing)
      end
    end
  end

  describe "#validate_booking" do
    context "valid" do
      it "passes for valid booking dates" do
        params = {
          tx_params: {
            start_on: 1.day.from_now.to_date,
            end_on: 2.days.from_now.to_date
          },
          quantity_selector: :day,
          stripe_in_use: false
        }

        expect(validator.validate_booking(params).success).to eq(true)
      end

      it "passes if booking is not in use" do
        params = {
          tx_params: {},
          quantity_selector: :number,
          stripe_in_use: false
        }

        expect(validator.validate_booking(params).success).to eq(true)
      end
    end

    context "invalid" do
      it "fails if start date is after end date" do
        params = {
          tx_params: {
            start_on: 1.day.from_now.to_date,
            end_on: 2.days.ago.to_date
          },
          quantity_selector: :day,
          stripe_in_use: false
        }

        expect(validator.validate_booking(params).data[:code]).to eq(:end_cant_be_before_start)
      end

      it "fails if start date equals end date for night selector" do
        params = {
          tx_params: {
            start_on: 1.day.from_now.to_date,
            end_on: 1.day.from_now.to_date
          },
          quantity_selector: :night,
          stripe_in_use: false
        }

        expect(validator.validate_booking(params).data[:code]).to eq(:at_least_one_day_or_night_required)
      end

      it "fails if start date or end date is missing for day selector" do
        params = {
          tx_params: {},
          quantity_selector: :day,
          stripe_in_use: false
        }

        expect(validator.validate_booking(params).data[:code]).to eq(:dates_missing)
      end

      it "fails if start date or end date is missing for night selector" do
        params = {
          tx_params: {},
          quantity_selector: :night,
          stripe_in_use: false
        }

        expect(validator.validate_booking(params).data[:code]).to eq(:dates_missing)
      end

      it "fails if start date is to late" do
        params = {
          tx_params: {
            start_on: 366.days.from_now.to_date,
            end_on: 367.days.from_now.to_date
          },
          quantity_selector: :day,
          stripe_in_use: false
        }

        expect(validator.validate_booking(params).data[:code]).to eq(:date_too_late)
      end

      it "fails if start date is to late. stripe in use" do
        params = {
          tx_params: {
            start_on: 86.days.from_now.to_date,
            end_on: 87.days.from_now.to_date
          },
          quantity_selector: :day,
          stripe_in_use: true
        }

        expect(validator.validate_booking(params).data[:code]).to eq(:date_too_late)
      end
    end
  end

  describe "#validate_transaction_agreement" do
    context "valid" do
      it "passes if agreement is in use and agreed" do
        params = {
          tx_params: {
            contract_agreed: true
          },
          transaction_agreement_in_use: true
        }

        expect(validator.validate_transaction_agreement(params).success).to eq(true)
      end

      it "passes if agreement is not in use" do
        params = {
          tx_params: {},
          transaction_agreement_in_use: false
        }

        expect(validator.validate_transaction_agreement(params).success).to eq(true)
      end

    end

    context "invalid" do
      it "fails if agreement is in use but not agreed" do
        params = {
          tx_params: {
            contract_agreed: false
          },
          transaction_agreement_in_use: true
        }

        expect(validator.validate_transaction_agreement(params).data[:code]).to eq(:agreement_missing)

      end
    end
  end
end
