#!/bin/bash
# echo Running the script.

cd ${HOME}/output/meme # should probably turn this into a CLI later, if integrating this into the pipeline
# ls

# Target directory where files will be copied
TARGET_DIR="${HOME}/copy_of_meme_outputs" # might turn this into a CLI later

# Ensure target directory exists
mkdir -p "$TARGET_DIR"

# Traverse subdirectories with max depth 2
find . -mindepth 3 -maxdepth 3 -type f \( -name "meme-chip.html" -o -name "summary.tsv" \) | while read -r file; do
    # Get the directory path relative to the current directory
    REL_DIR=$(dirname "$file")
    # echo $REL_DIR
    # Create the corresponding directory structure in the target directory
    mkdir -p "${TARGET_DIR}/${REL_DIR}"

    # Copy the file to the new location
    cp "$file" "${TARGET_DIR}/${REL_DIR}/"
done
