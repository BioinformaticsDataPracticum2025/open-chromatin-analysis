#!/bin/bash

# Step 6 (motif analysis) requires FASTA input.
# Use this script to convert bed outputs from step 5 (enhancers and promoters) to FASTA.

# Inputs:
# $1: $ref_fasta which is either h (human), m (mouse), or a filepath ending in .fasta
# (there are just too many equivalent file extensions for FASTA files... so just rename your file to end with .fasta)
# $2: $input_bed which is a filepath to the BED file you want to convert to a FASTA
# $3: $output_filename. If you want to put it in a new directory, please make the directory beforehand so that it exists.

# Output: a fasta file with the specified $output_filename, containing sequences at regions specified in $input_bed.


# Example run:
# bash convert_bed_to_fasta.sh h ~/output/step3_bedtools/human_ovary_to_pancreas_intersect_pancreasClosed.bed ~/input/getfasta_test_output.fasta
# I chose to put the output FASTA file in the "input" dir because it'll be used for step 6 motif analysis 

module load bedtools

# bedtools getfasta will generate an index file for the fasta input (which is used as a reference).
# However, you cannot just use the filepath to the ikaplow  copy of the fasta file,
# because the ikaplow directory is read-only and therefore it will fail to make the fasta file.
# So, you first need to copy the fasta to your own $PROJECT directory. Copy it to the $PROJECT directory,
# not the home directory, because your home directory doesn't have a lot of storage.

# If reference genome files don't already exist at these locations, copy them over.
if [[ ! -f "$PROJECT/hg38.fa" ]]; then
    echo "Copying human reference genome..."
    cp "$PROJECT/../ikaplow/HumanGenomeInfo/hg38.fa" "$PROJECT/hg38.fa"
fi

if [[ ! -f "$PROJECT/mm10.fa" ]]; then
    echo "Copying mouse reference genome..."
    cp "$PROJECT/../ikaplow/MouseGenomeInfo/mm10.fa" "$PROJECT/mm10.fa"
fi


# Assign command-line arguments
if [[ "$1" == "h" ]]; then
    ref_fasta="$PROJECT/hg38.fa"
elif [[ "$1" == "m" ]]; then
    ref_fasta="$PROJECT/mm10.fa"
elif [[ "$1" == *.fasta ]]; then
    ref_fasta="$1"
else
    echo "Invalid first argument: must be 'h', 'm', or a .fasta file. If it has another file extension, try changing the extension to .fasta."
    exit 1
fi

input_bed="$2"
output_filename="$3"

# Ensure input BED file exists
if [[ ! -f "$input_bed" ]]; then
    echo "Error: BED file '$input_bed' not found."
    exit 1
fi

# now we can actually run getfasta.
bedtools getfasta -fi $ref_fasta -bed $input_bed -fo $output_filename
