class PostsController < ApplicationController
  def index
    @posts = wp.getPosts(filter: {number: 1000, post_status: "publish"})
    @posts = @posts.reverse


    render json: @posts if request.format.json?
  end

  def show
    @post = wp.getPost(post_id: params[:id])
  end

  private 

  def wp
    Rubypress::Client.new(host: "weareallnatives.wordpress.com",
                      username: "weareallnatives", 
                      password: "changeme13",
                       use_ssl: true) 
  end
end
