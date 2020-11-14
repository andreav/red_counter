# Accessing container

    docker-compose exec redmine bash
    
    docker-compose exec mysql -u redmine redmine
    
    docker-compose exec mysql -u root -e "show grants for redmine; GRANT ALL PRIVILEGES ON *.* TO 'redmine'@'%'; show grants for redmine;"

# First login:

    cd /opt/bitnami/redmine
    bundle exec rails app:update:bin

    # fix bitnami config
    sed config/database.yml  -e 's/  adapter: postgresql/  adapter: mysql2/' -i

    sudo apt-get update
    sudo apt-get -y install   build-essential   ruby-all-dev   vim   postgresql-client libpq5 libpq-dev
    
    # unlock bundle install
    sed .bundle/config  -e 's/BUNDLE_DEPLOYMENT: "true"/BUNDLE_DEPLOYMENT: "false"/' -i

    bundle install --with=test

# Console

    bundle exec rails console --sandbox
    bundle exec rails console --sandbox -e test

# Restart server

    touch /opt/bitnami/redmine/tmp/restart.txt
    -- refresh browser

# Running tests
    
    cd /opt/bitnami/redmine
    
    export RAILS_ENV=test
    bundle exec rake db:drop
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake redmine:plugins:migrate
    bundle exec rake redmine:load_default_data   
    
    bundle exec rails  test plugins/red_counter/tests/functional/*        --backtrace
    bundle exec rails  test plugins/red_counter/tests/unit/*              --backtrace
    bundle exec rails  test plugins/red_counter/tests/unit/config_test.rb --backtrace -n /minutes/

    # bundle exec rake test:db -t
    # bundle exec rake redmine:plugins:test:units NAME=red_counter RAILS_ENV="test"

    # executing rake task
    RAILS_ENV=production ISSUES=24015 bundle exec rake red_counter:eval_time_spent

# Setup plugin

    1. Copy plugin

    2. bundle install

    3. restart redmine
    
    4. migrate
       bundle exec rails redmine:plugins:migrate RAILS_ENV=test
       bundle exec rails redmine:plugins:migrate RAILS_ENV=development
       bundle exec rails redmine:plugins:migrate RAILS_ENV=production

# Reset schema for single plugin

    drop table rc_configs;
    delete from schema_migrations where version like '%red_counter%';
    export RAILS_ENV=test
    exec rake redmine:plugins:migrate

# Import existing database

    docker cp ./a_db.sql $(docker-compose ps -q mariadb):/a_db.sql.sql
    docker-compose exec mariadb bash
       mysql -u redmine bitnami_redmine < /a_db.sql.sql
