describe URLUtils do
  it "#append_query_param" do
    expect(URLUtils.append_query_param("http://www.google.com", "q", "how to create a marketplace"))
      .to eql("http://www.google.com?q=how+to+create+a+marketplace")
    expect(URLUtils.append_query_param("http://www.google.com?q=how+to+create+a+marketplace", "start", "10"))
      .to eql("http://www.google.com?q=how+to+create+a+marketplace&start=10")
    end
  end
