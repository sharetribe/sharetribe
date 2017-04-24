module CustomLandingPage
  module Caching

    module_function

    def fetch_cache_meta(community_id, version, locale, cta)
      Rails.cache.read("clp/#{community_id}/#{version}/#{locale}/#{cta}")
    end

    def fetch_cached_content(community_id, version, digest)
      Rails.cache.read("clp/#{community_id}/#{version}/#{digest}")
    end

    def cache_content!(community_id, version, locale, content, cache_time, cta)
      cache_meta = build_cache_meta(content)

      # write metadata first, so that it expires first
      write_cache_meta!(
        community_id, version, locale, cache_meta, cache_time, cta)
      # cache html longer than metadata, but keyed by content (digest)
      write_cached_content!(
        community_id, version, content, cache_meta[:digest], cache_time + 10.seconds)
      cache_meta
    end


    ## Internal, use cache_content! instead
    def build_cache_meta(content)
      {last_modified: Time.now(), digest: Digest::MD5.hexdigest(content)}
    end

    ## Internal, use cache_content! instead
    def write_cache_meta!(community_id, version, locale, cache_meta, cache_time, cta)
      Rails.cache.write("clp/#{community_id}/#{version}/#{locale}/#{cta}", cache_meta, expires_in: cache_time)
    end

    ## Internal, use cache_content! instead
    def write_cached_content!(community_id, version, content, digest, cache_time)
      Rails.cache.write("clp/#{community_id}/#{version}/#{digest}", content, expires_in: cache_time)
    end

  end
end
