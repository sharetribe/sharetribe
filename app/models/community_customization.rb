class CommunityCustomization < ActiveRecord::Base

  attr_accessible :community_id,
    :description,
    :locale,
    :name,
    :slogan,
    :blank_slate,
    :welcome_email_content,
    :about_page_content,
    :how_to_use_page_content,
    :terms_page_content,
    :privacy_page_content,
    :storefront_label,
    :signup_info_content,
    :private_community_homepage_content,
    :verification_to_post_listings_info_content,
    :search_placeholder

  belongs_to :community

  def transaction_agreement_label
    # Move me to database!
    "I agree to this agreement"
  end

  def transaction_agreement_content
    # Move me to database!
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus tristique porta sem, eu ullamcorper leo fermentum at. Ut congue nibh odio, sed aliquam nisi luctus nec. Etiam auctor ac tellus ut faucibus. Ut rutrum condimentum quam, a convallis nulla facilisis quis. Fusce nulla neque, laoreet a odio a, porta fermentum neque. Curabitur quis libero orci. Donec dapibus, tellus et molestie tempus, est ligula mollis lacus, ac hendrerit odio libero quis odio. Nunc scelerisque libero odio, ac dignissim metus vestibulum sit amet. Integer ornare velit vel lectus facilisis suscipit. Donec lorem eros, lacinia et vehicula vitae, semper sed orci. Praesent suscipit ac magna nec imperdiet. Ut malesuada odio nec metus dapibus tincidunt. Vestibulum aliquet dignissim est et porta. Nulla sed quam tempus, varius metus lobortis, rutrum risus."
  end

end
