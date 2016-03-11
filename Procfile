web:         bundle exec passenger start -p $PORT --max-pool-size $PASSENGER_MAX_POOL_SIZE
worker:      bundle exec rake jobs:work --queue=default
css_compile: bundle exec rake jobs:work --queue=css_compile
