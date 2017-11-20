# Verify-commit-to-release-calculator

The script looks at all the repos listed out in `repo_list.txt` and it will pick the first n (this is set in the `calculate_difference.sh`) number of commits. It will determine the time at which each individual commit was last changed (this is defined as the commit date by git) and also the time that the release automation script tagged it with a release number. The difference (time taken for a developer to push the commit and the commit ending up being prepped for release) is calculated and all of the above information are captured into a file called `time_from_commit_to_release_logs.csv`.

## Running the script

In order to get the logs generated, simply clone the repo and run
`./generate_logs`.

## Changing the list of repos

The list of repos being looked at are listed out in the `repo_list.txt`. Edit
that list to your heart's desire to include/exclude any repos.

## Number of commits to look at

Edit `NUMBER_OF_COMMITS` in `calculate_difference.sh` to change how many commits
are looked at in each repo.

