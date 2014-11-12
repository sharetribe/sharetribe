class Superadmin::CommunitiesController < ApplicationController
  before_filter :ensure_is_superadmin
  skip_filter :dashboard_only

  def new
    @new_community = Community.new
    @transaction_types = TransactionTypeCreator::TRANSACTION_TYPES.map { |type, settings| [settings[:label], type] }
  end

  def create
    p = Maybe(params)

    defaults = {
      consent: "SHARETRIBE1.0"
    }

    language = p["language"].or_else("en")
    community_params = defaults.merge(p["community"].merge(settings: {"locales" => [language]}).get)

    @community = Community.create(community_params)
    if @community.save

      create_category!(p, language, @community)
      transaction_type = create_transaction_type!(p, @community)

      link = view_context.link_to "#{@community.domain}.#{APP_CONFIG.domain}", "//#{@community.domain}.#{APP_CONFIG.domain}"
      flash[:notice] = "Successfully created new community '#{@community.name(I18n.locale)}' (#{link})".html_safe

      redirect_to :superadmin_communities
    else
      flash[:error] = "Error: #{@community.errors.messages}"
      redirect_to new_superadmin_community_path
    end
  end

  def create_transaction_type!(p, community)
    type = p["transaction_type"].or_else("Sell")
    TransactionTypeCreator.create(community, type)
  end

  def create_category!(p, language, community)
    category = community.categories.build

    category.translations.build({
      :locale => language,
      :name => p[:category].or_else("Default")
    })

    category.save!
  end
end