module PaginationViewUtils

  module_function

  def parse_pagination_opts(pagination_opts = {}, default_per_page = 30)
    per_page = Maybe(pagination_opts)[:per_page].to_i.or_else(default_per_page)
    page = Maybe(pagination_opts)[:page].to_i.or_else(1)

    {
      per_page: per_page,
      page: page,
      limit: per_page,
      offset: per_page * (page - 1)
    }
  end

end
