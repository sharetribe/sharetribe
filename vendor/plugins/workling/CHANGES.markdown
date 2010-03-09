Version 0.4.2.3, 31.01.2009
- introduced Workling.raises_exceptions. by default, this is true in test and development to help with bug tracking. 
- added :threaded as the default spawn runner for test and development. helps problem tracing. 

Version 0.4.2.2, 29.11.08
- turned Workling.load_path into an Array.

Version 0.4.2.1, 27.11.08
- fixed raise exceptions if non existing worker methods are called

Version 0.4.2, 10.11.08
- added information about invokers and clients to the readme
- fixed dependence on amqp library
- nicer error messages with amqp / rabbitmq

Version 0.4.1 08.11.08
- added a generic client runner. deprecated starling_runner since it is now redundant
- moved connection exception handling code into MemcacheQueueClient and out of pollers

Version 0.4.0, 04.11.08
- more refactored clients and invokers. introduced clear base classes
- support for 3 invoker strategies: basic poller, threaded poller, eventmachine subscriber
- amqp support

Version 0.3.8, 03.11.08
- full support for rudeq
- refactored pollers. now now longer mainly about starling
- refactored starling client, converted to generalized memcachequeue client.
- changed runner script to be more generic

Version 0.3.1, 15.10.08
- fixed to autodiscovery code bugs. 
- introduced Workling::VERSION
- fixed test suite for the case that no memcache client is installed at all
- fixed AR reconnecting code for Multicore systems (Thanks Brent)

Version 0.3, 25.09.08
- added backgroundjob runner
- added automatic detection of starling, spawn and backgroundjob to set default runner
- made logging of exceptions more consistent across runners. 
- added friendlier error message if starling was started on the wrong port. 
- play nice without fiveruns-memcache-client. 
- added better documentation in README and RDOC

Version 0.2.5, 02.09.08
- added automatic setting of spawn runner if the spawn plugin is installed. 

Version 0.2.4, 08.06.08
- accept both async_ and asynch_ as prefixes for workling method invocation. thank you francois beausoleil!
- added memcached configuration options to workling.yml. see example yml for details. thank you larry diehl!
- re-raise exceptions if there is a problem adding an item to the starling queue. thank you digitalronin!
- added status script for starling client. thank you andrew carter!
- applied patches from dave dupre: http://davedupre.com/2008/03/29/ruby-background-tasks-with-starling-part-2/
  - added threading to starling poller. One polling thread can now be set to run per queue. 
  - default routing no longer producing queues like a:b:c, this was conflicting with MemCacheClient#stat
  - added handling for memcache exceptions
  - keep the database connection alive

Version 0.2.2, 15.02.08, rev 31
- added blaine cook's suggestion: worklings can now (also) be invoked like this: YourWorkling.asynch_your_method(options)
- added similar for remote store, which can now be called like this: Workling::Return::Store.set(:key, "value")

Version 0.2.1, 14.02.08 rev. 24
- added WorklingError classes.
- all runners now suppresses workling exceptions. This brings the local behaviour in line with the remote runners.

Version 0.2, 13.02.08 rev. 21
- progress bars or returning results now possible with return stores. use these to communicate back from your workling.
- memory store for testing and starling store added. 
- now generates uids for workling jobs. these are returned by the runner.
- extracted Workling::Clients::Starling
- clearer file structure for workling

Version 0.1, 06.02.08
- initial release
- see http://playtype.net/past/2008/2/6/starling_and_asynchrous_tasks_in_ruby_on_rails/ for details.