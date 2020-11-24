#!/usr/bin/ruby

routes = %x{ bundle exec rake routes }
routes = routes.gsub(/{.*}/, "")

puts routes

locale_matches = routes.scan(/\(\/:locale\)\/([^: ]+?)\//)
root_matches = routes.scan(/ \/([^: (.\/]+?)(?:\/|\(|\.)/)

puts (locale_matches + root_matches).uniq.sort.join(" ")
