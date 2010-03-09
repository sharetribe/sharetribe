# Todos for 0.5.0

* add a linting runner for tests. should check that no ar objects are being passed around
* add a mechanism for requiring models, for those people who insist on passing models across the wire
* add reloading of workers if Rails.reload?
* write some code that knows if the client should be started, and gives out a warning
* add a configuration option for SERVER/CLIENT
* add phusion daemon starter option so that workling_client doesn't need to be started manually on SERVER
* write some more documentation on the above issues and on standard remote setup. 
* create a public forum, rdoc site
* try to reduce user error in setting environments correctly
* add beanstalkd runner
* refactor starling* to be memcache*. add aliased classes into deprecated.rb.
* look into create method. is this being called more often than intended?
* add some monit and god scripts as starters
* try to catch more user setup errors which lead to worker code not being called

# Todos for 1.0

* gemify
* move all runner/invoker implementations out of workling
* move backend discovery code out of workling
* decide on a single backend to include in workling
* merb support
* test on jruby
* more runners: sqs