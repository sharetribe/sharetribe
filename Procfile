web:         bundle exec passenger start -p $PORT --max-pool-size $PASSENGER_MAX_POOL_SIZE
worker:      QUEUES=default,paperclip,mailers bundle exec rake jobs:work
css_compile: QUEUE=css_compile bundle exec rake jobs:work
