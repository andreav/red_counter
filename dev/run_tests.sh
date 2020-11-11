#|/bin/bash -e 

cd /opt/bitnami/redmine/

# Create test database
export RAILS_ENV=test

bundle exec rake db:drop
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake redmine:plugins:migrate
# yes en | bundle exec rake redmine:load_default_data   
#bundle exec rake test:db -t

# not working ...
#bundle exec rake redmine:plugins:test:units NAME=red_counter RAILS_ENV="test"
bundle exec   rails   test plugins/red_counter/tests/unit/*
bundle exec   rails   test plugins/red_counter/tests/functional/*
