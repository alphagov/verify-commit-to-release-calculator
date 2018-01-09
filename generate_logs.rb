#!/usr/bin/env ruby

require './calculate_difference.rb'

def git_clone(repo_name)
  if File.directory?(repo_name)
    Dir.chdir repo_name
    `git pull --rebase`
  else
    `git clone "git@github.com:alphagov/#{repo_name}"`
    Dir.chdir repo_name
  end
end

current_directory = Dir.pwd
git_clone("verify-release-logs")
Dir.chdir current_directory

repos = File.read("repo_list.txt").split("\n")
repos.each do |repo|
  git_clone(repo)

  log_file_name = "time_from_commit_to_release_#{repo}.csv"
  calculated_values = ["Sha,Commit date,Release date,Commit to release (hours),Tag"] + compute_difference(repo)

  output_dir_name = "../output"
  Dir.mkdir output_dir_name if !File.directory? output_dir_name
  IO.write("#{output_dir_name}/#{log_file_name}", calculated_values.join("\n"))
  Dir.chdir current_directory
  puts "Done with : #{repo}"
end

