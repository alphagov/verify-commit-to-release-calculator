#!/usr/bin/env ruby

require 'date'
require 'time_difference'

STARTDATE = '2017-2-1'
NUMBEROFCOMMITS = 2000

def get_tag(sha, tag)
  regex = tag == 'build' ? "'^#{tag}_\\d{2,}'" : "'#{tag}_\\d{2,}'"
  `git tag --contains #{sha}| egrep #{regex} | sort -t _ -k 2 -g | head -1`.chomp
end

repo_name = ARGV[0]
shas = `git log --after=#{STARTDATE} --format=format:%H -#{NUMBEROFCOMMITS}`.split("\n")

shas.each do |sha|
  release_tag = repo_name == 'verify-puppet' ? get_tag(sha, 'verify_puppet_release') : get_tag(sha, 'release')

  unless release_tag.empty?
    commit_date = `TZ=UTC git log -1 --format=%cd --date=local #{sha}`.chomp

    build_tag = get_tag(sha, 'build')
    build_tag_number = build_tag.delete("^0-9")
    build_tag_date = `git tag -l --format="%(taggerdate:format:%c)" #{build_tag}`.chomp

    release_tag_date = `git tag -l --format="%(taggerdate:format:%c)" #{release_tag}`.chomp
    parsed_release_tag_date = DateTime.parse(release_tag_date)

    time_from_commit_to_release_prep = TimeDifference.between(parsed_release_tag_date, DateTime.parse(commit_date)).in_hours
    time_from_aptly_to_release_prep = TimeDifference.between(parsed_release_tag_date, DateTime.parse(build_tag_date)).in_hours
    time_from_commit_to_aptly = time_from_commit_to_release_prep - time_from_aptly_to_release_prep

    puts "#{sha},#{commit_date},#{build_tag_date},#{release_tag_date},#{parsed_release_tag_date.month}/#{parsed_release_tag_date.year},#{time_from_aptly_to_release_prep},#{time_from_commit_to_release_prep},#{'%.2f' % time_from_commit_to_aptly},#{release_tag},#{repo_name}"
  end
end
