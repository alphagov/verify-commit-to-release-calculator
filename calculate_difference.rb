#!/usr/bin/env ruby

require 'date'
require 'time_difference'

STARTDATE = '2017-2-1'
NUMBEROFCOMMITS = 50

def get_tag(sha, tag)
  `git tag --contains #{sha}| grep #{tag} | head -1`.chomp
end

def construct_build_query_string(repo_name, build_tag_number)
  matrix = {
    'doc-checking' => ['dcs-audit-consumer', 'amd64'],
    'verify-frontend-federation-config' => ['verify-frontend-federation-config', 'all'],
    'verify-frontend-api' => ['frontend', 'amd64'],
    'ida-hub' => ['config', 'amd64'],
    'verify-frontend' => ['front-assets', 'amd64'],
    'verify-puppet' => ['ida-webops', 'all'],
    'ida-stub-idp' => ['stub-idp', 'amd64']
  }

  package_name, suffix = matrix[repo_name]
  if repo_name == 'verify-frontend'
    "https://packages.ida.digital.cabinet-office.gov.uk/main/#{package_name[0]}/#{package_name}-#{build_tag_number}/#{package_name}-#{build_tag_number}_1_#{suffix}.deb"
  else
    "https://packages.ida.digital.cabinet-office.gov.uk/main/#{package_name[0]}/#{package_name}/#{package_name}_#{build_tag_number}_#{suffix}.deb"
  end
end

repo_name = ARGV[0]
shas = `git log --after=#{STARTDATE} --format=format:%H -#{NUMBEROFCOMMITS}`.split("\n")

shas.each do |sha|
  release_tag = repo_name == 'verify_puppet' ? get_tag(sha, 'verify_puppet_release') : get_tag(sha, 'release')

  unless release_tag.empty?
    build_tag_number = get_tag(sha, 'build').delete("^0-9")
    build_query_string = construct_build_query_string(repo_name, build_tag_number)
    build_artifact_date = `curl -sI #{build_query_string} | awk 'NR==6{print $0}' | cut -d ' ' -f2-`.chomp

    commit_date = `TZ=UTC git log -1 --format=%cd --date=local #{sha}`.chomp
    tag_date = `git tag -l --format="%(taggerdate:format:%c)" #{release_tag}`.chomp

    time_from_commit_to_release_prep = TimeDifference.between(DateTime.parse(tag_date), DateTime.parse(commit_date)).in_hours
    time_from_aptly_to_release_prep = TimeDifference.between(DateTime.parse(tag_date), DateTime.parse(build_artifact_date)).in_hours

    puts "#{sha},#{commit_date},#{tag_date},#{time_from_commit_to_release_prep},#{time_from_aptly_to_release_prep },#{release_tag},#{repo_name}"
  end
end
