# Here we stub these injected methods to return nil, because they rely on
# custom fields, and setting it up can be messy.
#
# https://github.com/coopdevs/sharetribe/pull/33#issuecomment-640650610
def stub_donalo_stuff
  allow_any_instance_of(Listing).to receive(:stock).and_return(nil)
  allow_any_instance_of(Listing).to receive(:minimum_required_units).and_return(nil)
end
