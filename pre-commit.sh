#!/bin/sh

# Pre-commit hook used to keep debugging code out of the repository

EXIT=0

git stash -q --keep-index

FILES_PATTERN='\.(js|coffee)(\..+)?$'
FORBIDDEN='console.log'
git diff --cached --name-only -S$FORBIDDEN | grep -q -E $FILES_PATTERN && \
    echo "COMMIT REJECTED, found forbidden '$FORBIDDEN' in:\n" && \
    git diff --cached --name-only -S$FORBIDDEN | grep -E $FILES_PATTERN && echo "\n" && EXIT=1

 FILES_PATTERN='\.(rb|erb|haml|slim|coffee)(\..+)?$'
 FORBIDDEN='binding.pry'
git diff --cached --name-only -S$FORBIDDEN | grep -q -E $FILES_PATTERN && \
    echo "COMMIT REJECTED, found forbidden '$FORBIDDEN' in:\n" && \
    git diff --cached --name-only -S$FORBIDDEN | grep -E $FILES_PATTERN && echo "\n" && EXIT=1

git stash pop -q

if [ $EXIT -eq 1 ] ; then exit 1 ; fi
