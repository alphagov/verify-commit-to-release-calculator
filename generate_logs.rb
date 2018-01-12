#!/usr/bin/env ruby

require './calculate_difference.rb'

HEADERS = 'Sha,Commit date,Build date,Release date,Commit to build(hours),Commit to release (hours),Tag'

ROOT_DIR = Dir.pwd
OUTPUT_DIR = ROOT_DIR + '/release-time-graphs-app/output'
REPOS_DIR = ROOT_DIR + '/repos'
REPO_LIST = ROOT_DIR + '/repo_list.txt'

def git_clone(repo)
  Dir.mkdir REPOS_DIR unless File.directory? REPOS_DIR
  Dir.chdir REPOS_DIR

  File.directory?(repo) ?
    `cd #{repo} && git pull --rebase` :
    `git clone git@github.com:alphagov/#{repo}`

  Dir.chdir repo
end

git_clone('verify-release-logs')
repos = File.read(REPO_LIST).split("\n")

repos.each do |repo|
  git_clone(repo)

  puts 'Calculating values for repository : ' + repo

  log_file_name = "time_from_commit_to_release_#{repo}.csv"
  calculated_values = [HEADERS] + compute_difference(repo)

  Dir.mkdir OUTPUT_DIR unless File.directory? OUTPUT_DIR
  IO.write("#{OUTPUT_DIR}/#{log_file_name}", calculated_values.join("\n"))
  puts "\nDone with : #{repo}"
end

