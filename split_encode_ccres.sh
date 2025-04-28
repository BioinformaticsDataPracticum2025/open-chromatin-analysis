#!/bin/bash

# The purpose of this script is to split an ENCODE cCREs file into promoters and enhancers.
# For your convenience, we've provided mouse and human cCREs that have already been split.

# However, if you are studying a different species, you can use this script to split the corresponding ENCODE cCREs file.
# Instructions on how to download the input:
# This function expects an ENCODE cCREs BED file downloaded from the UCSC Table Browser https://genome.ucsc.edu/cgi-bin/hgTables
# Under the "Retrieve and display data" menu, select the "Output format" of "Selected fields from primary and related tables",
# enter a filename so that it downloads instead of opening in the browser, choose tsv format, and gzip it.
# Click "Get output", and on the next page, select the following four columns:
# chrom, chromStart, chromEnd, and ucscLabel.
# The first three columns are the contents of a typical BED file, while the fourth column is comprised of "prom", "enhD", or "enhP"
# which are the annotations that will be used to separate the entries into promoters ("prom") and enhancers (everything else).
# IMPORTANT: This script is not built to work with any fourth column that is not ucscLabel.

# Input:
# $1: a gzipped BED file with the format described above
# Example run:
# bash split_encode_ccres.sh "${HOME}/input/ENCODE_cCREs_human.txt.gz"

# Output: two files, one containing the promoters and one containing the enhancers

# Check for input argument
if [ -z "$1" ]; then
  echo "Error: No input file provided."
  echo "Usage: bash $0 <input_file>"
  exit 1
fi

# Define input file and directory
input_file="$1"
input_dir=$(dirname "$input_file")
base_name=$(basename "$input_file" .gz)

# Unzip file only if it is gzipped
if [[ "$input_file" == *.gz ]]; then
  gunzip -c "$input_file" > "$input_dir/$base_name"  # Decompress but keep original gzipped file
  input_file="$input_dir/$base_name"
fi

# Define output file paths
promoters_file="${input_file%.*}_promoters.bed"
enhancers_file="${input_file%.*}_enhancers.bed"

# Split ENCODE file into promoters and enhancers
awk '$4 == "prom"' "$input_file" > "$promoters_file"
awk '$4 != "prom"' "$input_file" > "$enhancers_file"

# Echo the locations of the new files
echo "Promoters file saved to: $promoters_file"
echo "Enhancers file saved to: $enhancers_file"
