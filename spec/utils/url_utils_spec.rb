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
end
