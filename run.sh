set -e
bundle install && ./generate_logs.rb
cd release-time-graphs-app 
bundle install && rails s
