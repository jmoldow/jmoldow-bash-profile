#!/bin/sh
# `man 1 git`, section "Git Diffs", environment variable GIT_EXTERNAL_DIFF
# $1path $2old-file $3old-hex $4old-mode $5new-file $6new-hex $7new-mode
sem diff $2 $5
