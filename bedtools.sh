#!/bin/bash

# take input as a txt file with five cols:
# file_A     file_B     output_file     intersection_mode   name

# For intersection_mode:
# y: open in both
# n: open in file_A, closed in file_B


module load bedtools

if ! command -v bedtools &> /dev/null; then
    echo "Error: bedtools is not installed. Please install bedtools and try again."
    exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 input_list.txt"
    exit 1
fi

preprocess_file() {
    local infile="$1"
    local outfile="$2"
    if [[ "$infile" == *.gz ]]; then
        zcat "$infile" | sort -k1,1 -k2,2n > "$outfile"
    else
        sort -k1,1 -k2,2n "$infile" > "$outfile"
    fi
}

check_file_exists() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "Error: File '$file' does not exist. Terminating."
        exit 1
    fi
}

input_list="$1"

# check the input txt file 
[ -f "$input_list" ] || { echo "Error: Input file '$input_list' not found."; exit 1; }

# arrays for plotting
names_arr=()
dataA_arr=()
dataB_arr=()

while read -r line || [[ -n "$line" ]]; do
    if [[ -z "$line" || $line == \#* ]]; then
        continue
    fi

    filename_a=$(echo "$line" | awk '{print $1}')
    filename_b=$(echo "$line" | awk '{print $2}')
    out=$(echo "$line" | awk '{print $3}')
    mode=$(echo "$line" | awk '{print $4}')
    name=$(echo "$line" | awk '{print $5}')

    check_file_exists "$filename_a"
    check_file_exists "$filename_b"

    file_a=$(mktemp)
    file_b=$(mktemp)

    # unzip peak files and sort by genomic coordinate 
    preprocess_file "$filename_a" "$file_a"
    preprocess_file "$filename_b" "$file_b"

    if [ "$mode" = "y" ]; then
        echo "Intersecting (open in both):"
        echo "  File A: $filename_a"
        echo "  File B: $filename_b"
        bedtools intersect -a "$file_a" -b "$file_b" -u > "$out"
    elif [ "$mode" = "n" ]; then
        echo "Intersecting (open in file_a, closed in file_b):"
        echo "  File A: $filename_a"
        echo "  File B: $filename_b"
        bedtools intersect -a "$file_a" -b "$file_b" -v > "$out"
    else
        echo "Error: Invalid mode '$mode' for line:"
        echo "$line"
        echo "Skipping."
        continue
    fi

    # counting 
    count_a=$(wc -l < "$file_a")
    count_b=$(wc -l < "$file_b")
    avg=$(echo "scale=2; ($count_a + $count_b)/2" | bc)
    numerator=$(wc -l < "$out")

    percentage=$(echo "scale=2; $numerator / $avg" | bc)
    echo Percentage of hits for the intersection that created $out: $percentage

    names_arr+=("$name")
    dataA_arr+=("$avg")
    dataB_arr+=("$numerator")

    rm -f "$file_a" "$file_b"

done < "$input_list"


names=$(IFS=, ; echo "${names_arr[*]}")
dataA=$(IFS=, ; echo "${dataA_arr[*]}")
dataB=$(IFS=, ; echo "${dataB_arr[*]}")

# check dependencies 
python -c "import numpy" > /dev/null 2>&1 || {
    echo "Error: numpy is not installed. Please install numpy."
    exit 1
}

python -c "import matplotlib" > /dev/null 2>&1 || {
    echo "Error: matplotlib is not installed. Please install matplotlib."
    exit 1
}

python python_scripts/plot_radial.py --names "$names" --dataA "$dataA" --dataB "$dataB"
