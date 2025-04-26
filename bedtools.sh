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

# preprocess_file() {
#    local infile="$1"
#    local outfile="$2"
#    if [[ "$infile" == *.gz ]]; then
#        zcat "$infile" | sort -k1,1 -k2,2n > "$outfile"
#    else
#        sort -k1,1 -k2,2n "$infile" > "$outfile"
#    fi
# }

check_file_exists() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "Error: File '$file' does not exist. Terminating."
        exit 1
    fi
}

# input_list="$1"

# check the input txt file 
# [ -f "$input_list" ] || { echo "Error: Input file '$input_list' not found."; exit 1; }

# arrays for plotting
# names_arr=()
# dataA_arr=()
# dataB_arr=()



filename_a=$1
filename_b=$2
out=$3
mode=$4
# name=$5

check_file_exists "$filename_a"
check_file_exists "$filename_b"


# unzip peak files and sort by genomic coordinate 
zcat $filename_a | sort -k1,1 -k2,2n > temp_a.bed
zcat $filename_b | sort -k1,1 -k2,2n > temp_b.bed


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

percentage=$(echo "scale=2; $numerator / $denominator" | bc)
echo Percentage of hits calculated as number of lines in $filename_a over number of lines in $out: $percentage

# names_arr+=("$name")
# dataA_arr+=("$denominator")
# dataB_arr+=("$numerator")

# Jaccard calculation
jaccard=$(bedtools jaccard -a temp_a.bed -b temp_b.bed | tail -n1 | awk '{ printf "%.4f", $3 * 100 }')
# echo "Jaccard overlap for the intersection that created $out: $jaccard%"
echo "$jaccard"

rm -f temp_a.bed temp_b.bed


# names=$(IFS=, ; echo "${names_arr[*]}")
# dataA=$(IFS=, ; echo "${dataA_arr[*]}")
# dataB=$(IFS=, ; echo "${dataB_arr[*]}")

# # check dependencies 
# python -c "import numpy" > /dev/null 2>&1 || {
#     echo "Error: numpy is not installed. Please install numpy."
#     exit 1
# }

# python -c "import matplotlib" > /dev/null 2>&1 || {
#     echo "Error: matplotlib is not installed. Please install matplotlib."
#     exit 1
# }

# python python_scripts/plot_radial.py --names "$names" --dataA "$dataA" --dataB "$dataB"
