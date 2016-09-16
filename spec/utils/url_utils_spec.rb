require 'active_support/core_ext/object'
[
  "app/utils/url_utils",
  "app/utils/hash_utils",
].each { |f| require_relative "../../#{f}" }

describe URLUtils do
  it "#append_query_param" do
    expect(URLUtils.append_query_param("http://www.google.com", "q", "how to create a marketplace"))
      .to eql("http://www.google.com?q=how+to+create+a+marketplace")
    expect(URLUtils.append_query_param("http://www.google.com?q=how+to+create+a+marketplace", "start", "10"))
      .to eql("http://www.google.com?q=how+to+create+a+marketplace&start=10")
  end

  it "#remove_query_param" do
    expect(URLUtils.remove_query_param("http://www.google.com?q=how+to+create+a+marketplace", "q"))
      .to eql("http://www.google.com")
    expect(URLUtils.remove_query_param("http://www.google.com?q=how+to+create+a+marketplace&start=10", "q"))
      .to eql("http://www.google.com?start=10")
    expect(URLUtils.remove_query_param("http://www.google.com?q=how+to+create+a+marketplace&start=10", "start"))
      .to eql("http://www.google.com?q=how+to+create+a+marketplace")
  end

  it "#extract_locale_from_url" do
    expect(URLUtils.extract_locale_from_url('http://www.sharetribe.com/')).to eql(nil)
    expect(URLUtils.extract_locale_from_url('http://www.sharetribe.com/en/people')).to eql('en')
    expect(URLUtils.extract_locale_from_url('http://www.sharetribe.com/en-US/people')).to eql('en-US')
  end

  it "#strip_port_from_host" do
    expect(URLUtils.strip_port_from_host("www.sharetribe.com")).to eql("www.sharetribe.com")
    expect(URLUtils.strip_port_from_host("www.sharetribe.com:3000")).to eql("www.sharetribe.com")
  end

  it "#build_url" do
    expect(URLUtils.build_url("http://www.example.com/", { intParam: 1, strParam: "foo"}))
      .to eql "http://www.example.com/?intParam=1&strParam=foo"

    expect(URLUtils.build_url("https://www.example.com", { intParam: 1, nilParam: nil, strParam: "foo"}))
      .to eql "https://www.example.com?intParam=1&strParam=foo"

    expect(URLUtils.build_url("www.example.com", { intParam: 1, nilParam: nil, strParam: "foo"}))
      .to eql "www.example.com?intParam=1&strParam=foo"
  end

  describe "#join" do

    def expect_url_join(*parts)
      expect(URLUtils.join(*parts))
    end

    it "joins absolute paths" do
      expect_url_join("//example.com").to eq("//example.com")
      expect_url_join("//example.com", "foo").to eq("//example.com/foo")
      expect_url_join("//example.com", "foo", "bar").to eq("//example.com/foo/bar")

      expect_url_join("https://example.com").to eq("https://example.com")
      expect_url_join("https://example.com", "foo").to eq("https://example.com/foo")
      expect_url_join("https://example.com", "foo", "bar").to eq("https://example.com/foo/bar")

      expect_url_join("https://example.com/", "foo/").to eq("https://example.com/foo/")
      expect_url_join("https://example.com/", "foo/", "bar/").to eq("https://example.com/foo/bar/")

      expect_url_join("https://example.com/", "foo/", "/bar/").to eq("https://example.com/foo/bar/")
    end

    it "joins relative paths" do
      expect_url_join(nil, "foo").to eq("foo")
      expect_url_join("", "foo").to eq("foo")
      expect_url_join("", "", "foo", "", "bar", "", "").to eq("foo/bar")
      expect_url_join("foo").to eq("foo")
      expect_url_join("foo/").to eq("foo/")
      expect_url_join("/", "foo").to eq("/foo")
      expect_url_join("/foo/", "bar/", "baz").to eq("/foo/bar/baz")
      expect_url_join("foo/", "bar/", "baz").to eq("foo/bar/baz")

      expect_url_join("/foo/").to eq("/foo/")
      expect_url_join("/", "foo/", "bar/").to eq("/foo/bar/")

      expect_url_join("/", "/foo/", "/bar/").to eq("/foo/bar/")
    end
  end

  describe "asset_host?" do
    it "returns true if host and asset host are equal" do
      expect(
        URLUtils.asset_host?(
          host: "assets.sharetribe.com",
          asset_host: "assets.sharetribe.com")
      ).to eq(true)

      expect(
        URLUtils.asset_host?(
          host: "app.sharetribe.com",
          asset_host: "assets.sharetribe.com")
      ).to eq(false)
    end

    it "allows %d wildcards" do
      expect(
        URLUtils.asset_host?(
          host: "assets3.sharetribe.com",
          asset_host: "assets%d.sharetribe.com")
      ).to eq(true)

      expect(
        URLUtils.asset_host?(
          host: "assets3.subserver2.sharetribe.com",
          asset_host: "assets%d.subserver%d.sharetribe.com")
      ).to eq(true)
    end

  end
end
