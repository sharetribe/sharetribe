class PostsController < ApplicationController
  def index
    wp = Rubypress::Client.new(:host => "weareallnatives.wordpress.com", 
                           :username => "weareallnatives", 
                           :password => "changeme12",
                           :use_ssl  => true)

    @posts = wp.getPosts
  end
end
