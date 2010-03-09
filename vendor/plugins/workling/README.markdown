# Workling

Workling gives your Rails App a simple API that you can use to make code run in the background, outside of the your request. 

You can configure how the background code will be run. Currently, workling supports Starling, BackgroundJob and Spawn Runners. Workling is a bit like Actve* for background work: you can write your code once, then swap in any of the supported background Runners later. This keeps things flexible. 

## Installing Workling

The easiest way of getting started with workling is like this: 

    script/plugin install git://github.com/purzelrakete/workling.git
    script/plugin install git://github.com/tra/spawn.git 

If you're on an older Rails version, there's also a subversion mirror wor workling (I'll do my best to keep it synched) at:

    script/plugin install http://svn.playtype.net/plugins/workling/

## Writing and calling Workers

This is pretty easy. Just put `cow_worker.rb` into into `app/workers`, and subclass `Workling::Base`:

    # handle asynchronous mooing.
    class CowWorker < Workling::Base 
      def moo(options)
        cow = Cow.find(options[:id])
        logger.info("about to moo.")
        cow.moo
      end
    end

Make sure you have exactly one hash parameter in your methods, workling passes the job :uid into here. Btw, in case you want to follow along with the Mooing, grab 'cows-not-kittens' off github, it's an example workling project. Look at the branches, there's one for each Runner.

Next, you'll want to call your workling in a controller. Your controller might looks like this: 

    class CowsController < ApplicationController
  
      # milking has the side effect of causing
      # the cow to moo. we don't want to
      # wait for this while milking, though,
      # it would be a terrible waste ouf our time.
      def milk
        @cow = Cow.find(params[:id])
        CowWorker.asynch_moo(:id => @cow.id)
      end
    end

Notice the `asynch_moo` call to `CowWorker`. This will call the `moo` method on the `CowWorker` in the background, passing any parameters you like on. In fact, workling will call whatever comes after asynch_ as a method on the worker instance. 

## Worker Lifecycle

All worker classes must inherit from this class, and be saved in `app/workers`. The Worker is loaded once, at which point the instance method `create` is called. 

Calling `async_my_method` on the worker class will trigger background work. This means that the loaded Worker instance will receive a call to the method `my_method(:uid => "thisjobsuid2348732947923")`. 

## Exception handling in Workers

If an exception is raised in your Worker, it will not be propagated to the calling code by workling. This is because the code is called asynchronously, meaning that exceptions may be raised after the calling code has already returned. If you need your calling code to handle exceptional situations, you have to pass the error into the return store. 

Workling does log all exceptions that propagate out of the worker methods. 

## Logging with Workling

`RAILS_DEFAULT_LOGGER` is available in all workers. Workers also have a logger method which returns the default logger, so you can log like this: 

    logger.info("about to moo.")

## What should I know about the Spawn Runner?

Workling automatically detects and uses Spawn, if installed. Spawn basically forks Rails every time you invoke a workling. To see what sort of characteristics this has, go into script/console, and run this: 

    >> fork { sleep 100 } 
    => 1060 (the pid is returned)

You'll see that this executes pretty much instantly. Run 'top' in another terminal window, and look for the new ruby process. This might be around 30 MB. This tells you that using spawn as a runner will result low latency, but will take at least 30MB for each request you make. 

You cannot run your workers on a remote machine or cluster them with spawn. You also have no persistence: if you've fired of a lot of work and everything dies, there's no way of picking up where you left off. 

# Using the Starling runner

If you want cross machine jobs with low latency and a low memory overhead, you might want to look into using the Starling Runner. 

## Installing Starling

As of 27. September 2008, the recommended Starling setup is as follows:

    gem sources -a http://gems.github.com/ 
    sudo gem install starling-starling 
    mkdir /var/spool/starling 

The robot Co-Op Memcached Gem version 1.5.0 has several bugs, which have been fixed in the fiveruns-memcache-client gem. The starling-starling gem will install this as a dependency. Refer to the fiveruns README to see what the exact fixes are. 

The Rubyforge Starling gem is also out of date. Currently, the most authorative Project is starling-starling on github (27. September 2008). 

Workling will now automatically detect and use Starling, unless you have also installed Spawn. If you have Spawn installed, you need to tell Workling to use Starling by putting this in your environment.rb: 

    Workling::Remote.dispatcher = Workling::Remote::Runners::StarlingRunner.new

## Starting up the required processes

Here's what you need to get up and started in development mode. Look in config/workling.yml to see what the default ports are for other environments. 

    sudo starling -d -p 22122
    script/workling_client start

## Configuring workling.yml

Workling copies a file called workling.yml into your applications config directory. The config file tells Workling on which port Starling is listening. 

Notice that the default production port is 15151. This means you'll need to start Starling with -p 15151 on production. 

You can also use this config file to pass configuration options to the memcache client which workling uses to connect to starling. use the key 'memcache_options' for this. 

You can also set sleep time for each Worker. See the key 'listeners' for this. Put in the modularized Class name as a key. 

    development:
      listens_on: localhost:22122
      sleep_time: 2
      reset_time: 30
      listeners:
        Util:
          sleep_time: 20
      memcache_options:
        namespace: myapp_development
        
    production:
      listens_on: localhost:22122, localhost:221223, localhost:221224
      sleep_time: 2
      reset_time: 30
      
Note that you can cluster Starling instances by passing a comma separated list of values to 
        
Sleep time determines the wait time between polls against polls. A single poll will do one .get on every queue (there is a corresponding queue for each worker method).

If there is a memcache error, the Poller will hang for a bit to give it a chance to fire up again and reset the connection. The wait time can be set with the key reset_time.

## Seeing what Starling is doing

Starling comes with it's own script, starling_top. If you want statistics specific to workling, run:

    script/starling_status.rb

## A Quick Starling Primer

You might wonder what exactly starling does. Here's a little snippet you can play with to illustrate how it works: 

     4 # Put messages onto a queue:
     5 require 'memcache'
     6 starling = MemCache.new('localhost:22122')
     7 starling.set('my_queue', 1)
     8 
     9 # Get messages from the queue:
    10 require 'memcache'
    11 starling = MemCache.new('localhost:22122')
    12 loop { puts starling.get('my_queue') }
    13
    
# Using RabbitMQ or any Queue Server that supports AMQP

RabbitMQ is a reliable, high performance queue server written in erlang. If you're doing high volume messaging and need a high degree of reliability, you should definitely consider using RabbitMQ over Starling. 

A lot of Ruby people have been talking about using RabbitMQ as their Queue of choice. Soundcloud.com are using it, as is new bamboo founder Johnathan Conway, who is using it at his video startup http://www.vzaar.com/. He says: 

> RabbitMQ – Now this is the matrons knockers when it comes to kick ass, ultra fast and scalable messaging. It simply rocks, with performance off the hook. It’s written in Erlang and supports the AMPQ protocol. 

If you're on OSX, you can get started with RabbitMQ by following the installation instructions [here](http://playtype.net/past/2008/10/9/installing_rabbitmq_on_osx/). To get an idea of how to directly connect to RabbitMQ using ruby, have a look at [this article](http://playtype.net/past/2008/10/10/kickass_queuing_over_ruby_using_amqp).

Once you've installed RabbitMQ, install the ruby amqp library: 

    gem sources -a http://gems.github.com/ (if necessary)
    sudo gem install tmm1-amqp
    
then configure configure your application to use Amqp by adding this: 

    Workling::Remote.invoker = Workling::Remote::Invokers::EventmachineSubscriber
    Workling::Remote.dispatcher = Workling::Remote::Runners::ClientRunner.new
    Workling::Remote.dispatcher.client = Workling::Clients::AmqpClient.new
    
Then start the workling Client: 

    1 ./script/workling_client start

You're good. 

# Using RudeQueue

RudeQueue is a Starling-like Queue that runs on top of your database and requires no extra processes. Use this if you don't need very fast job processing and want to avoid managing the extra process starling requires.

Install the RudeQ plugin like this:

    1 ./script/plugin install git://github.com/matthewrudy/rudeq.git
    2 rake queue:setup
    3 rake db:migrate
    
Configure Workling to use RudeQ. Add this to your environment:

    Workling::Clients::MemcacheQueueClient.memcache_client_class = RudeQ::Client
    Workling::Remote.dispatcher = Workling::Remote::Runners::ClientRunner.new
    
Now start the Workling Client: 

    1 ./script/workling_client start
    
You're good.

# Using BackgroundJob

If you don't want to bother with seperate processes, are not worried about latence or memory footprint, then you might want to use Bj to power workling. 

Install the Bj plugin like this:

    1 ./script/plugin install http://codeforpeople.rubyforge.org/svn/rails/plugins/bj
    2 ./script/bj setup

Workling will now automatically detect and use Bj, unless you have also installed Starling. If you have Starling installed, you need to tell Workling to use Bj by putting this in your environment.rb: 

    Workling::Remote.dispatcher = Workling::Remote::Runners::BackgroundjobRunner.new

# Progress indicators and return stores

Your worklings can write back to a return store. This allows you to write progress indicators, or access results from your workling. As above, this is fairly slim. Again, you can swap in any return store implementation you like without changing your code. They all behave like memcached. For tests, there is a memory return store, for production use there is currently a starling return store. You can easily add a new return store (over the database for instance) by subclassing `Workling::Return::Store::Base`. Configure it like this in your test environment:

    Workling::Return::Store.instance = Workling::Return::Store::MemoryReturnStore.new
    
Setting and getting values works as follows. Read the next paragraph to see where the job-id comes from. 

    Workling.return.set("job-id-1", "moo")
    Workling.return.get("job-id-1")           => "moo"

Here is an example worker that crawls an addressbook and puts results into a return store. Workling makes sure you have a :uid in your argument hash - set the value into the return store using this uid as a key:

    require 'blackbook'
    class NetworkWorker < Workling::Base
      def search(options)
        results = Blackbook.get(options[:key], options[:username], options[:password])
        Workling.return.set(options[:uid], results)
      end
    end

call your workling as above: 

    @uid = NetworkWorker.asynch_search(:key => :gmail, :username => "foo@gmail.com", :password => "bar")

you can now use the @uid to query the return store:   

    results = Workling.return.get(@uid)

of course, you can use this for progress indicators. just put the progress into the return store. 

enjoy!

## Adding new work brokers to Workling

There are two new base classes you can extend to add new brokers. I'll describe how this is done usin amqp as an example. The code i show is already a part of workling.

### Clients

Clients help workling to connect to job brokers. To add an AmqpClient, we need to extend from `Workling::Client::Base` and implement a couple of methods. 

    require 'workling/clients/base'
    require 'mq'

    #
    #  An Ampq client
    #
    module Workling
      module Clients
        class AmqpClient < Workling::Clients::Base
      
          # starts the client. 
          def connect
            @amq = MQ.new
          end
      
          # stops the client.
          def close
            @amq.close
          end
      
          # request work
          def request(queue, value)
            @amq.queue(queue).publish(value)
          end
          
          # retrieve work
          def retrieve(queue)
            @amq.queue(queue)
          end
          
          # subscribe to a queue
          def subscribe(queue)
            @amq.queue(queue).subscribe do |value|
              yield value
            end
          end
          
        end
      end
    end

Were's using the eventmachine amqp client for this, you can find it [up on github](http://github.com/tmm1/amqp/tree/master). `connect` and `close` do exactly what it says on the tin: connecting to rabbitmq and closing the connection. 

`request` and `retrieve` are responsible for placing work on rabbitmq. The methods are passed the correct queue, and a value that contains the worker method arguments. If you need control over the queue names, look at the RDoc for Workling::Routing::Base. In our case, there's no special requirement here. 

Finally, we implement a `subscribe` method. Use this if your broker supports callbacks, as is the case with amqp. This method expects to a block, which we pass into the amqp subscribe method here. The block will be called when a message is available on the queue, and the result is yielded into the block. 

Having subscription callbacks is very nice, because this way, we don't need to keep calling `get` on the queue to see if something new is waiting. 

So now we're done! That's all you need to add RabbitMQ to workling. Configure it in your application as descibed below. 

### Invokers

There's still potential to improve things though. Workling 0.4.0 introduces the idea of invokers. Invokers grab work off a job broker, using a client (see above). They subclass Workling::Remote::Invokers::Base. Read the RDoc for a description of the methods. 

Workling comes with a couple of standard invokers, like the BasicPoller. This invoker simply keeps hitting the broker every n seconds, checking for new work and executing it immediately. The ThreadedInvoker does the same, but spawns a Thread for every Worker class the project defines. 

So Amqp: it would be nice if we had an invoker that makes use of the subscription callbacks. Easily done, lets have a look: 

    require 'eventmachine'
    require 'workling/remote/invokers/base'

    #
    #  Subscribes the workers to the correct queues. 
    # 
    module Workling
      module Remote
        module Invokers
          class EventmachineSubscriber < Workling::Remote::Invokers::Base
      
            def initialize(routing, client_class)
              super
            end
      
            #
            #  Starts EM loop and sets up subscription callbacks for workers. 
            #
            def listen
              EM.run do
                connect do
                  routes.each do |queue|
                    @client.subscribe(queue) do |args|
                      run(queue, args)
                    end
                  end
                end
              end
            end
              
            def stop
              EM.stop if EM.reactor_running?
            end
          end
        end
      end
    end

Invokers have to implement two methods, `listen` and `stop`. Listen starts the main listener loop, which is responsible for starting work when it becomes available. 

In our case, we need to start an EM loop around `listen`. This is because the Ruby AMQP library needs to run inside of an eventmachine reactor loop. 

Next, inside of `listen`, we need to iterate through all defined routes. There is a route for each worker method you defined in your application. The routes double as queue names. For this, you can use the helper method `routes`. Now we attach a callback to each queue. We can use the helper method `run`, which executes the worker method associated with the queue, passing along any supplied arguments. 

That's it! We now have a more effective Invoker.

# Contributors

The following people contributed code to workling so far. Many thanks :) If I forgot anybody, I aplogise. Just drop me a note and I'll add you to the project so that you can amend this!

Anybody who contributes fixes (with tests), or new functionality (whith tests) which is pulled into the main project, will also be be added to the project.

* Andrew Carter (ascarter)
* Chris Gaffney (gaffneyc)
* Matthew Rudy (matthewrudy)
* Larry Diehl (reeze)
* grantr (francios)
* David (digitalronin)
* Dave Dupré
* Douglas Shearer (dougal)
* Nick Plante (zapnap)
* Brent
* Evan Light (elight)

Copyright (c) 2008 play/type GmbH, released under the MIT license
