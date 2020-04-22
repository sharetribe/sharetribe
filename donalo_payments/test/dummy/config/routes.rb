Rails.application.routes.draw do
  mount DonaloPayments::Engine => "/donalo_payments"
end
