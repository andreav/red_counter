#|/bin/bash -e 

cd /opt/bitnami/redmine/

# bitnami place postgres on test database config
sed config/database.yml  -e 's/  adapter: postgresql/  adapter: mysql2/' -i

# bundle install
sudo apt-get update
sudo apt-get -y install   build-essential   ruby-all-dev   vim   postgresql-client libpq5 libpq-dev
sed .bundle/config  -e 's/BUNDLE_DEPLOYMENT: "true"/BUNDLE_DEPLOYMENT: "false"/' -i
bundle install --with=test

