set -e
bundle install && ./generate_logs.sh
cd release-time-graphs-app 
bundle install && rails s
