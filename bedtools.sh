#!/bin/bash

# take 5 CLIs as input:
# bash bedtools.sh file_A file_B output_file intersection_mode name

# For intersection_mode:
# y: open in both
# n: open in file_A, closed in file_B

# Example usage:
# bash bedtools.sh ~/output/hal/Mouse/Ovary/peaks.MouseToHuman.HALPER.narrowPeak.gz $PROJECT/../ikaplow/HumanAtac/Ovary/peak/idr_reproducibility/idr.conservative_peak.narrowPeak.gz ~/input/test_bedtools.bed y testname


module load bedtools

if ! command -v bedtools &> /dev/null; then
    echo "Error: bedtools is not installed. Please install bedtools and try again."
    exit 1
fi

# if [ "$#" -ne 1 ]; then
#    echo "Usage: $0 input_list.txt"
#    exit 1
# fi

# Helper function for sorting
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


filename_a=$1
filename_b=$2
out=$3
mode=$4

check_file_exists "$filename_a"
check_file_exists "$filename_b"


# unzip peak files (if necessary) and sort by genomic coordinate 
preprocess_file $filename_a temp_a.bed
preprocess_file $filename_b temp_b.bed
# zcat $filename_a | sort -k1,1 -k2,2n > temp_a.bed
# zcat $filename_b | sort -k1,1 -k2,2n > temp_b.bed


if [ "$mode" = "y" ]; then
    echo "Intersecting (open in both):"
    echo "  File A: $filename_a"
    echo "  File B: $filename_b"
    bedtools intersect -a temp_a.bed -b temp_b.bed -u | cut -f1-3 > "$out"
elif [ "$mode" = "n" ]; then
    echo "Intersecting (open in file_a, closed in file_b):"
    echo "  File A: $filename_a"
    echo "  File B: $filename_b"
    bedtools intersect -a temp_a.bed -b temp_b.bed -v | cut -f1-3 > "$out"
else
    echo "Error: Invalid mode '$mode' for line:"
    echo "$line"
    echo "Skipping."
    continue
fi

# counting 
denominator=$(wc -l < temp_a.bed)
numerator=$(wc -l < "$out")

# calculate the percentage File A’s entries that passed the intersection
percentage=$(echo "scale=2; $numerator / $denominator" | bc)
echo Percentage of hits calculated as number of lines in $filename_a over number of lines in $out: $percentage

# Jaccard calculation
jaccard=$(bedtools jaccard -a temp_a.bed -b temp_b.bed | tail -n1 | awk '{ printf "%.4f", $3 * 100 }')
echo "$jaccard"

rm -f temp_a.bed temp_b.bed