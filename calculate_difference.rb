#!/usr/bin/env ruby

require 'date'
require 'time_difference'
require './repo_to_release_log_name.rb'


def get_tags(sha, tag)
  regex = "'#{tag}_\\d{2,}'"
  `git tag --contains #{sha}| egrep #{regex} | sort -t _ -k 2 -g`.split("\n")
end

def get_release_date (release_tag, sha, repo_name)
  commit_date = `TZ=UTC git log -1 --format=%cd --date=local #{sha}`.chomp
  release_tag_number = release_tag.delete("^0-9")
  log_name = REPO_HASH[:"#{repo_name}"]
  release_date = `find ../verify-release-logs -maxdepth 1 -type d -execdir git grep -i -h -e "#{log_name}" --and -e '"#{release_tag_number}"' --and -e "Send release complete email" \\; | jq ".end_time"`.chomp
  if !release_date.empty?
      parsed_release_date = DateTime.parse(release_date)
      time_from_commit_to_release = TimeDifference.between(parsed_release_date, DateTime.parse(commit_date)).in_hours
      "#{sha},#{commit_date},#{release_date},#{time_from_commit_to_release},#{release_tag}"
  end
end

def compute_difference(repo_name)
  return_value = []
  shas = `git log --after="1 year ago" --format=format:%H`.split("\n")

  shas.each do |sha|
    release_tags = get_tags(sha, 'release')

    release_tags.each do |release_tag|
      line = get_release_date(release_tag, sha, repo_name)
      if line
        return_value << line
        break
      end
    end
  end
  return_value
end