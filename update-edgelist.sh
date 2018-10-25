#! /bin/bash
# execute the tangled.R script and update the github state
# set -e will bail out on any error, such as in the tangled.R script
set -e
git checkout master
Rscript update_edgelist.R
git add ./data
git commit ./data
git push
