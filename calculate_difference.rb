#!/usr/bin/env ruby

require 'date'
require 'time_difference'
require './repo_to_release_log_name.rb'

STARTDATE = '2017-2-1'
NUMBEROFCOMMITS = 2000

def get_tag(sha, tag)
  regex = tag == 'build' ? "'^#{tag}_\\d{2,}'" : "'#{tag}_\\d{2,}'"
  `git tag --contains #{sha}| egrep #{regex} | sort -t _ -k 2 -g | head -1`.chomp
end

def compute_difference(repo_name)
  return_value = []
  shas = `git log --after=#{STARTDATE} --format=format:%H -#{NUMBEROFCOMMITS}`.split("\n")
  shas.each do |sha|
    release_tag = get_tag(sha, 'release')

    unless release_tag.empty?
      commit_date = `TZ=UTC git log -1 --format=%cd --date=local #{sha}`.chomp
      parsed_repo_name=repo_name.tr('-', ' ')
      release_tag_number = release_tag.delete("^0-9")
      release_date = `find ../verify-release-logs -maxdepth 1 -type d -execdir git grep -i -h -e "#{REPO_HASH[parsed_repo_name]}" --and -e '"#{release_tag_number}"' --and -e "Send release complete email" \\; | jq ".end_time"`.chomp
      if !release_date.empty?
          parsed_release_date = DateTime.parse(release_date)
          time_from_commit_to_release = TimeDifference.between(parsed_release_date, DateTime.parse(commit_date)).in_hours
          return_value << "#{sha},#{commit_date},#{release_date},#{time_from_commit_to_release},#{release_tag}"
      end
    end
  end
  return_value
end