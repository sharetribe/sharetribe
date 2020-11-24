# MethodDeprecator

## Basics

MethodDeprecator is an implementation of class
[`ActiveSupport::Deprecation`](http://api.rubyonrails.org/classes/ActiveSupport/Deprecation.html). [`ActiveSupport`](http://guides.rubyonrails.org/active_support_core_extensions.html)
is the Ruby on Rails component providing core extensions for basic Ruby functionality. Ruby on Rails requires all of this functionality by default.

In addition, every [`Class`](http://ruby-doc.org/core-2.2.0/Class.html) has as a superclass a [`Module`](http://ruby-doc.org/core-2.2.0/Module.html). `ActiveSupport` provides an extension to `Module`, which defines a method [`deprecate`](http://api.rubyonrails.org/classes/Module.html#method-i-deprecate).

Therefore, `deprecate` can be called from every class and module inside the Sharetribe application that inherits from those two aforementioned classes.

By default, `deprecate` will print a notification about method being deprecated in the next Rails version. It takes as a named parameter an optional `:deprecator`, where we can define our own functionality. This is provided by `MethodDeprecator`.

`MethodDeprecator` is included in `config/application.rb` and is therefore usable everywhere in the app.

## Examples

``` ruby
class LaunchControl
  def launch_apollo
    puts "Apollo, lift-off!!"
  end

  def launch_shuttle
    puts "Shuttle, lift-off!"
  end

  def launch_soyuz
    puts "Союз, отрываться"
  end


  deprecate_method launch_apollo: "Apollo hasn't gone to the moon for a while, use launch_soyuz instead.",
                   launch_shuttle: "Shuttle isn't in service anymore. Use launch_soyuz instead.",
                   deprecator: MethodDeprecator.new
end


lctl = LaunchControl.new
lctl.launch_apollo   # => DEPRECATION WARNING: launch_apollo is deprecated and will be removed in future. |
                     #    Apollo hasn't gone to the moon for a while, use launch_soyuz instead. (called from <main> at (pry):41
lctl.launch_shuttle  # => DEPRECATION WARNING: launch_apollo is deprecated and will be removed in future. |
                     #    Shuttle isn't in service anymore. Use launch_soyuz instead. (called from <main> at (pry):43
```
