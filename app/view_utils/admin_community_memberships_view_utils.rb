module AdminCommunityMembershipsViewUtils

  module_function

  # Displaying X accepted users and Y banned users
  def community_members_entries_info(community_id, collection, options = {})
    model_key = 'person'
    if options.fetch(:html, true)
      b = '<b>'
      eb = '</b>'
      sp = '&nbsp;'
      html_key = '_html'
    else
      b = eb = html_key = ''
      sp = ' '
    end

    model_count = collection.total_pages > 1 ? 5 : collection.size
    defaults = ["models.#{model_key}"]
    defaults << proc { |_, opts|
      opts[:count] == 1 ? name : name.pluralize
    }

    accepted_count = CommunityMembership.where(community_id: community_id, status: "accepted").count
    accepted_model = will_paginate_translate defaults, :count => accepted_count
    banned_count = CommunityMembership.where(community_id: community_id, status: "banned").count
    banned_model = will_paginate_translate defaults, :count => banned_count

    model_count = collection.total_pages > 1 ? 5 : collection.size
    model_name = will_paginate_translate defaults, :count => model_count

    keys = nil
    params = nil
    if collection.total_pages < 2
      i18n_key = :"community_members_entries_info.single_page#{html_key}"
      keys = [:"#{model_key}.#{i18n_key}", i18n_key]
      params = {
        count: collection.total_entries,
        model: model_name,
        accepted_count: accepted_count,
        accepted_model: accepted_model,
        banned_count: banned_count,
        banned_model: banned_model
      }
    else
      i18n_key = :"community_members_entries_info.multi_page#{html_key}"
      keys = [:"#{model_key}.#{i18n_key}", i18n_key]
      params = {
        model: model_name,
        count: collection.total_entries,
        from: collection.offset + 1,
        to: collection.offset + collection.length,
        accepted_count: accepted_count,
        accepted_model: accepted_model,
        banned_count: banned_count,
        banned_model: banned_model
      }
    end
    will_paginate_translate keys, params
  end

  def will_paginate_translate(keys, options = {})
    if defined? ::I18n
      defaults = Array(keys).dup
      defaults << Proc.new if block_given?
      ::I18n.translate(defaults.shift, options.merge(:default => defaults, :scope => :will_paginate))
    else
      key = keys.is_a?(Array) ? keys.first : keys
      yield key, options
    end
  end
end
