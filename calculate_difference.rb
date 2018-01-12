#!/usr/bin/env ruby

require 'date'
require 'time_difference'
require './repo_to_release_log_name.rb'

RELEASE_COMPLETION_STEP = 'Send release complete email'

def get_tags(sha, tag)
  regex = "'#{tag}_\\d{2,}'"
  regex = regex.prepend '^' if tag == :build
  `git tag --contains #{sha}| egrep #{regex} | sort -t _ -k 2 -g`.split("\n")
end

def grep_release_date(log_name, release_tag_number)
  `find ../verify-release-logs -maxdepth 1 -type d -execdir git grep -i -h -e "#{log_name}" --and -e '"#{release_tag_number}"' --and -e "#{RELEASE_COMPLETION_STEP}" \\; | jq ".end_time"`.chomp
end

def get_release_date(release_tag, sha, repo_name)
  log_name = REPO_TO_VERIFY_LOGS_MAPPING[repo_name]
  release_tag_number = release_tag.delete('^0-9')
  release_date = grep_release_date(log_name, release_tag_number)

  return if release_date.empty?

  commit_date = `TZ=UTC git log -1 --format=%cd --date=local #{sha}`.chomp

  build_tag = get_tags(sha, :build)[0]
  build_date = `git tag -l --format="%(taggerdate:format:%c)" #{build_tag}`.chomp

  parsed_build_date = DateTime.parse(build_date)
  parsed_release_date = DateTime.parse(release_date)

  time_from_commit_to_build = TimeDifference.between(parsed_build_date, DateTime.parse(commit_date)).in_hours
  time_from_commit_to_release = TimeDifference.between(parsed_release_date, DateTime.parse(commit_date)).in_hours
  [sha,commit_date,build_date,release_date,time_from_commit_to_build,time_from_commit_to_release,release_tag].join(',')
end

def compute_difference_for_sha(sha, repo_name)
  release_tags = get_tags(sha, :release)
  release_tags.each do |release_tag|
    line = get_release_date(release_tag, sha, repo_name)
    return line if line
  end
end

def compute_difference(repo_name)
  shas = `git log --after="1 year ago" --format=format:%H`.split("\n")
  puts "SHA count: #{shas.count}"
  shas.map do |sha|
    putc '.'
    compute_difference_for_sha sha, repo_name
  end.compact
end
