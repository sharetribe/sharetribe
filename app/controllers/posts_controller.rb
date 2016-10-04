class PostsController < ApplicationController
  def index
    wp = Rubypress::Client.new(:host => "weareallnatives.wordpress.com", 
                           :username => "weareallnatives", 
                           :password => "changeme12",
                           :use_ssl  => true)

    @posts = wp.getPosts(filter: {number: 1000, post_status: "publish"})
    @posts = @posts.reverse


    render json: @posts if request.format.json?
  end
end
