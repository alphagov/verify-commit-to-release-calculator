#!/usr/bin/env bash
NUMBER_OF_COMMITS=1000

shas=$(git log --format=format:%H -$NUMBER_OF_COMMITS)
for sha in $shas; do
  commitdate=$(git log -1 --format=%cd --date=format:%c $sha)
  commitdateunix=$(git log -1 --format=%ct $sha)
  tag=$(git tag --contains $sha | grep release | head -1)
  if [[ -n "${tag}" ]]; then
    tagdate=$(git tag -l --format="%(taggerdate:format:%c)" $tag)
    tagdateunix=$(git tag -l --format="%(taggerdate:format:%s)" $tag)
    timetaken=$(awk "BEGIN {printf \"%.1f\",($tagdateunix-$commitdateunix)/3600}")
    echo "$sha,$commitdate,$tagdate,$timetaken,$tag,$1"
  fi
done

