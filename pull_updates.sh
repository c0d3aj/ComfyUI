#!/bin/bash

# Change the root directory to your desired location
root_directory="./custom_nodes"

# Loop through each subdirectory in the root directory
for dir in "$root_directory"/*/; do
    if [ -d "$dir/.git" ]; then
        echo "Pulling in $dir"
        (cd "$dir" && git pull)
    fi
done
