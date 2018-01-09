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

## Number of commits to look at

Edit `NUMBER_OF_COMMITS` in `calculate_difference.rb` to change how many commits
are looked at in each repo.

