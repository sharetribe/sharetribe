# Middleware for creating routes.js bundle.
#
# Usage:
#
# config.middleware.use JsRoutes::Middleware
#
# By default the middleware is watching the `config/routes.rb`
# file. If you have splitted your routes file into multiple files, you
# need to pass the files to the middleware in `route_files` option:
#
# config.middleware.use JsRoutes::Middleware, route_files: [
#   Rails.root.join('config/routes.rb'),
#   Rails.root.join('config/routes_admin.rb')
# ]
#
# ### Caching
#
# The middleware implements a simple cache: It saves the times when
# the files were changed to the 'tmp/cache/routes.yml' file.
#
# To clean the cache, run:
#
# `rake tmp:cache:clear`
#
# The cache is cleared everytime you restart the Rails server.
#
# ### Inspiration
#
# The implementation is heavily inspired by i18n-js middleware:
# https://github.com/fnando/i18n-js/
#
class JsRoutes
  class Middleware

    DEFAULT_ROUTE_FILES = [Rails.root.join("config/routes.rb")]

    def initialize(app, opts = {})
      @app = app
      @route_files = opts[:route_files] || DEFAULT_ROUTE_FILES

      ensure_files_exist!
      clear_cache
    end

    def call(env)
      @cache = nil
      verify_route_files!
      @app.call(env)
    end

    private

    def ensure_files_exist!
      non_existing_files = @route_files.reject(&:exist?)

      unless non_existing_files.empty?
        throw ArgumentError.new(
                "Route files do not exist: #{non_existing_files.join(',')}")
      end
    end

    def cache_path
      @cache_path ||= cache_dir.join("routes.yml")
    end

    def cache_dir
      @cache_dir ||= Rails.root.join("tmp/cache")
    end

    def cache
      @cache ||= begin
        if cache_path.exist?
          YAML.load_file(cache_path) || {}
        else
          {}
        end
      end
    end

    def clear_cache
      File.delete(cache_path) if File.exist?(cache_path)
    end

    def save_cache(new_cache)
      # path could be a symbolic link
      FileUtils.mkdir_p(cache_dir) unless File.exist?(cache_dir)
      File.open(cache_path, "w+") do |file|
        file << new_cache.to_yaml
      end
    end

    # Check if routes.js should be regenerated.
    # ONLY REGENERATE when these conditions are met:
    #
    # # Cache file doesn't exist
    # # Route files and cache size are different (files were removed/added)
    # # Routes file has been updated
    #
    def verify_route_files!
      valid_cache = []
      new_cache = {}

      valid_cache.push(cache_path.exist?)
      valid_cache.push(@route_files.uniq.size == cache.size)

      @route_files.each do |path|
        changed_at = File.mtime(path).to_i
        valid_cache.push(changed_at == cache[path])
        new_cache[path] = changed_at
      end

      return if valid_cache.all?

      save_cache(new_cache)

      JsRoutes.generate!
    end
  end
end
