require "awesome_print"

# Use Awesome Print for pretty printing Ruby objects
AwesomePrint.pry!

if Kernel.const_defined?(:Rails) && Rails.env
  require File.join(Rails.root,"config","environment")
  require 'rails/console/app'
  require 'rails/console/helpers'

  extend Rails::ConsoleMethods
end
