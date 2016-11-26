class Payments::BraintreeController < ApplicationController
    SERVICE_FEE = "1.00"
    def purchase_new
        listing_id = params[:listing_id]
        @listing = Listing.where(listing_id: listing_id, community_id: @current_community.id)
        if @current_user.is_buyer?
            gon.client_token = Braintree::ClientToken.generate(customer_id: @current_user.braintree_customer_id)
        else
            gon.client_token = Braintree::ClientToken.generate
        end
    end

    def purchase
        # Something
        listing_id = params[:listing_id]
        @listing = Listing.where(listing_id: listing_id, community_id: @current_community.id)
        if @current_user.is_buyer?
            result = Braintree::Transaction.sale(
                        :amount => "100.00",
                        #:merchant_account_id => "blue_ladders_store", #do this after merchant
                        :payment_method_nonce => @current_user.braintree_customer_id,
                        :options => {
                            :submit_for_settlement => true
                        },
                        :service_fee_amount => SERVICE_FEE
                     )
              if result.success?
                  render :text => "payment successfull"
              else
                  render :text => "payment unsuccessfull"
              end
        else
            @current_user.update_attribute(:braintree_customer_id, params[:payment_method_nonce])
            result = Braintree::Transaction.sale(
                        :amount => "100.00",
                        #:merchant_account_id => "blue_ladders_store", #do this after merchant
                        :payment_method_nonce => @current_user.braintree_customer_id,
                        :options => {
                            :submit_for_settlement => true
                        },
                        :service_fee_amount => SERVICE_FEE
                     )
              if result.success?
                  render :text => "payment successfull"
              else
                  render :text => "payment unsuccessfull"
              end
        end
    end
end
