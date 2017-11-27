#!/usr/bin/env bash

set -eu

curdir=$PWD
repos=$(cat ./repo_list.txt)
log_file_name="time_from_commit_to_release_logs.csv"

[ -f $log_file_name ] && rm $log_file_name
echo "Sha,Commit date,Build tag date,Release tag date,Release month,Aptly to release prep (hours),Commit to release prep (hours),Commit to aptly (hours),Tag,Repo" > $log_file_name

for repo in $repos
do
  if [ -d "$repo" ]; then
    cd "$repo" && git pull --rebase
  else
    git clone "git@github.com:alphagov/$repo"
    cd "$repo"
  fi
  ../calculate_difference.rb $repo | tee -a ../$log_file_name
  cd "$curdir"
done

