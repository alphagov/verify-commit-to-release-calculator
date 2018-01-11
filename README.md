# Verify-commit-to-release-calculator

The script looks at all the repos listed out in `repo_list.txt` and it will pick the first n (this is set in the `calculate_difference.rb`) number of commits. 

The difference (time taken between developer's last changes and the commit ending up being released) 
is calculated and all of the above information are captured in `output` folder

## Running the script

In order to get the logs generated, simply clone the repo and run
`./run.sh`.

## Changing the list of repos

The list of repos being looked at are listed out in the `repo_list.txt`. Edit
that list to your heart's desire to include/exclude any repos.

You will also need to edit `repo_to_release_log_name.rb` to add a mapping between the repo's name and how it is referred to in Verify Release Logs. This is so we can find the relevant release logs.
 
 ## Assumptions
 
1. We are only looking at commits up to 1 year ago
1. If a release has been aborted*, we use the next sequential release tag to find out production release time.
1. Removing all commit lead times to production that is taking more than 1000 hours since they are likely outliers

\*  We define a successful release as a release that has reached the `Send release complete email` step within Verify Release Logs. Anything without this is considered an aborted release.