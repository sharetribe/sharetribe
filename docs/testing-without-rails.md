# Testing without Rails

Loading the Rails environment takes a lot of time. A simple RSpec spec might take 10s just because it needs to load the full Rails environment.

It's good idea to decouple the application logic from Rails. This also means that you are able to test the logic without Rails.

Here's an example. The same RSpec suite with and without Rails:

With Rails:

```
.............
➜  sharetribe git:(harmony-client) ✗ time rspec spec/utils/service_client/middleware

Finished in 6.33 seconds (files took 6.41 seconds to load)
13 examples, 0 failures

rspec spec/utils/service_client/middleware  10.16s user 1.97s system 87% cpu 13.862 total
```

Without Rails:

```
➜  sharetribe git:(harmony-client) ✗ time rspec spec/utils/service_client/middleware
.............


Finished in 0.01922 seconds (files took 0.52468 seconds to load)
13 examples, 0 failures

rspec spec/utils/service_client/middleware  1.03s user 0.25s system 89% cpu 1.421 total
```

As you can see, the speed improvement is quite significant. In this case, the Rails version is 10x slower.

## How to test without Rails?

In RSpec, the `require 'spec_helper'` that you are used to add to each spec file, will load Rails environment. So, to test without Rails, simply do NOT add this line.

The effect is that:

* The test is super fast
* Rails auto-loading doesn't kick in
* ActiveSupport is not included

The last two points need to be fixed. Here's how.

### Rails auto-loading doesn't kick in

Because you're not requiring Rails, the Rails auto-loading doesn't do file loading for you. You need to do this manually in each spec. However, this snippet has been pretty handy and easy to use:

```ruby
[
  "app/services/my_logic",
  "app/utils/my_utility",
  "app/utils/my_utility_2",
].each { |f| require_relative "../../../../#{f}" }
```

### ActiveSupport is not included

Even if your code is not Rails specific, you're probably using ActiveSupport's monkey-patches in your code. Methods like `.present?` and `.blank?` will break because they are undefined.

You can fix this by including the parts of ActiveSupport you need, see: http://edgeguides.rubyonrails.org/active_support_core_extensions.html

**Examples:**

To include only core extensions to `Object`, use:

```ruby
require 'active_support'
require 'active_support/core_ext/object'
```

To include the full ActiveSupport, use:

```ruby
require 'active_support/all'
```
## TODO

Starting from RSpec 3.x, the required way to avoid loading Rails is to have two helper files:

* `spec_helper`: General configurations and helpers. Nothing Rails specific. Doesn't load Rails.
* `rails_helper`: Rails specific helpers. Loads Rails environment. Requires `spec_helper`

We haven't splitted our `spec_helper` file yet. Hopefully in that will happen in the future.
