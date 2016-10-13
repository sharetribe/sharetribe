module PostsHelper
	def resize_wordpress_thumbnail(url, width = 300)
		url.gsub(/w=\d*/, "w=#{width}")
	end
end