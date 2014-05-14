class Superadmin::CommunitiesController < ApplicationController
  before_filter :ensure_is_superadmin
  skip_filter :dashboard_only

  TRANSACTION_TYPES = {
    "Give" => {
      label: "Give",
      translation_key: "admin.transaction_types.give",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer"
    },
    "Inquiry" => {
      label: "Inquiry",
      translation_key: "admin.transaction_types.inquiry",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.inquiry"
    },
    "Lend" => {
      label: "Lend",
      translation_key: "admin.transaction_types.lend",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer"
    },
    "Rent" => {
      label: "Rent",
      translation_key: "admin.transaction_types.rent",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.rent"
    },
    "Request" => {
      label: "Request",
      translation_key: "admin.transaction_types.request",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.request"
    },
    "Sell" => {
      label: "Sell",
      translation_key: "admin.transaction_types.sell",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.sell"
    },
    "Service" => {
      label: "Service",
      translation_key: "admin.transaction_types.service",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer"
    },
    "ShareForFree" => {
      label: "Share for free",
      translation_key: "admin.transaction_types.share_for_free",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer"
    },
    "Swap" => {
      label: "Swap",
      translation_key: "admin.transaction_types.swap",
      action_button_translation_key: "admin.transaction_types.default_action_button_labels.offer"
    }
  }

  def new
    @new_community = Community.new
    @transaction_types = TRANSACTION_TYPES.map { |type, settings| [settings[:label], type] }
  end

  def create
    p = Maybe(params)

    defaults = {
      consent: "SHARETRIBE1.0",
      feedback_to_admin: 1,
      logo_change_allowed: 1,
      terms_change_allowed: 1,
      privacy_policy_change_allowed: 1,
      custom_fields_allowed: 1,
      category_change_allowed: 1
    }

    language = p["language"].or_else("en")
    community_params = defaults.merge(p["community"].merge(settings: {"locales" => [language]}).get)

    @community = Community.create(community_params)
    if @community.save

      transaction_type = create_transaction_type!(p, language, @community)
      create_category!(p, language, transaction_type, @community)

      link = view_context.link_to "#{@community.domain}.#{APP_CONFIG.domain}", "//#{@community.domain}.#{APP_CONFIG.domain}"
      flash[:notice] = "Successfully created new community '#{@community.name}' (#{link})".html_safe

      redirect_to :superadmin_communities
    else
      flash[:error] = "Error: #{@community.errors.messages}"
      redirect_to new_superadmin_community_path
    end
  end

  def create_transaction_type!(p, language, community)
    type = p["transaction_type"].or_else("Sell")
    transaction_type_description = TRANSACTION_TYPES[type]

    transaction_type = type.constantize.new
    transaction_type.community = community
    transaction_type.save!
    community.transaction_types << transaction_type

    transaction_type_translation = TransactionTypeTranslation.create({
      transaction_type_id: transaction_type.id,
      locale: language,
      name: t(transaction_type_description[:translation_key], :locale => language.to_sym),
      action_button_label: t(transaction_type_description[:action_button_translation_key], :locale => language.to_sym)
    });

    transaction_type
  end

  def create_category!(p, language, transaction_type, community)
    category = community.categories.create;

    category_translations = CategoryTranslation.create(:category_id => category.id,
      :locale => language,
      :name => p[:category].or_else("Default"));

    CategoryTransactionType.create(:category_id => category.id, :transaction_type_id => transaction_type.id)

    category
  end
end