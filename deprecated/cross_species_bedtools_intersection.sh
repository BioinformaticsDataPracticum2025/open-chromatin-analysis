#!/bin/bash

# Step 2a of the project: intersect peak data from the same tissue in different species

# usage: bash cross_species_bedtools_intersection.sh $1 $2 $3 $4
# $1 and $2 are input files to bedtools, $3 is the name of the output file,
# $4 specifies whether to look for regions that are open in both genomes ("y") or closed in the second genome ("n")

module load bedtools

cd ~/output/step2a_bedtools 
# I navigated to my own output directory for convenience, but you could put the output directory in the output filename


# In a full run of the script, you do the following steps:
# 1. generate the bed file from intersecting the two files (HALPER file which maps peaks from the source to target species,
# with the ATAC-seq peak data for the target species)
# 2. get the numerator by counting the lines in that intersected bed file
# 3. get the denominator by taking the average of the line counts in the two input files
# 4. print the percentage of hits (numerator divided by denominator) next to the filename.

# Step 1:
# Here, the source species is mouse, and the target species is human. The tissue is the ovary.
# We use the mouse-to-human HALPER output file and the human ATAC-seq file.
# The order of -a and -b matters because we are using the -u (unique) flag. The number of hits changes based on the order.
# I decided to put the HALPER file first because I wanted to see what genes each ortholog intersected with.
# I think HALPER joined together the fragments into contiguous orthologs,
# resulting in the HALPER output file having fewer hits. Contrast with the ATAC-seq file, which wasn't put through HALPER.
# I think the ATAC-seq file may have fragments that weren't joined together, leading to a lot of spurious hits.
# For reference: the ordering shown below had a line count of 15440, but if you switch -a and -b, it's 24258.

# Example values of variables:
# a=/jet/home/kwang18/output/hal/Mouse/Ovary/peaks.MouseToHuman.HALPER.narrowPeak.gz
# b=/ocean/projects/bio230007p/ikaplow/HumanAtac/Ovary/peak/idr_reproducibility/idr.conservative_peak.narrowPeak.gz
# out=ovary_intersect_mouse_peaks_to_human_coords_open.bed

# Using CLIs:
a=$1
b=$2
out=$3
both_open=$4 # either "y" or "n"; will not take other values

# Depending on the type of analysis, run with or without the -v flag
# I did a bit of testing, and the outputs of "bedtools intersect -a $a -b $b -u | wc -l"
# and "bedtools intersect -a $a -b $b -v | wc -l" do sum up to the same number as "zcat $a | wc -l",
# so I am fairly sure that these statements are both correct.

# To prepare the output file for upload to GREAT, we cut it to the first three columns.
# (GREAT complains if the input BED has more than 3 columns.)

if [ "$both_open" = "y" ]; then
    # looking for regions open in both input files
    echo "Looking for regions that are open in both input files."
    bedtools intersect -a $a -b $b -u | cut -f 1-3 > $out 
elif [ "$both_open" = "n" ]; then
    # looking for regions open in -a but closed in -b; use -v instead of -u
    echo "Looking for regions that are open in ${a} but closed in ${b}."
    bedtools intersect -a $a -b $b -v | cut -f 1-3 > $out # (can't use -u and -v together)
else
    echo "Error: Invalid value for the fourth CLI specifying whether to search for regions open in both genomes. Expected 'y' or 'n'."
    exit 1
fi


# Step 2:
# save the number of lines in the intersected output as the numerator variable (using cut in order to discard all the text after the first space)
numerator=$(wc -l $out | cut -d " " -f 1)
echo Number of intersections found: $numerator

# Step 3:
# For the denominator, simply use the number of lines in the input $a file
# IMPORTANT: these are compressed .gz files, so you actually have to use zcat, otherwise the line count will be
# much lower than it should be. As part of the pipeline, I think we can assume these files are compressed
# because when I unzipped the inputs to halLiftover and HALPER, I unzipped to a different location.
# get the average in two steps: first add together d1 and d2, then divide their sum by 2.
denominator=$(zcat $a | wc -l | cut -d " " -f 1)
echo Number of genes in input A: $denominator

# Step 4:
# need to use awk script to do floating point division
percentage=$(awk "BEGIN {print $numerator / $denominator}") # awk script for floating point division
echo Percentage for $out: $numerator / $denominator = $percentage

# Step 5:
# Find the Jaccard between the two input files $a and $b, as it's a better metric when they're very different in size
# Base pair level similarity using Jaccard index; it is a symmetric metric 
# The output is saved to a txt file and printed as a percentage overlap (extracted from the third column of output)

# Human: Ovary vs Pancreas
echo Jaccard overlap:
zcat $a | sort -k1,1 -k2,2n > ~/input/temp_a.bed
zcat $b | sort -k1,1 -k2,2n > ~/input/temp_b.bed
echo $(bedtools jaccard -a ~/input/temp_a.bed -b ~/input/temp_b.bed | tail -n 1 | awk '{printf "%.4f", $3 * 100}') "%"


# My part of the project is to do cross-species intersections (different species, same tissue).
# Here are the $a, $b, and $out values to use for each of these intersections.
# You should probably use a loop to pass these as CLIs into this script.

# Mouse to human ovary intersection (both open)
a="/jet/home/kwang18/output/hal/Mouse/Ovary/peaks.MouseToHuman.HALPER.narrowPeak.gz"
b="/ocean/projects/bio230007p/ikaplow/HumanAtac/Ovary/peak/idr_reproducibility/idr.conservative_peak.narrowPeak.gz"
out="ovary_intersect_mouse_peaks_to_human_coords_open.bed"
both_open="y"

# Mouse to human ovary intersection (open in mouse, closed in human)
# same $a and $b as directly above, but use the -v flag instead of -u
out="ovary_intersect_mouse_peaks_to_human_coords_humanClosed.bed"
both_open="n"

# Human to mouse ovary intersection (both open)
# This does have a different line count and percentage than "Mouse to human ovary intersection (both open)".
# Is it because we used optimal peaks for the mouse and conservative peaks for the human?
a="/jet/home/kwang18/output/hal/Human/Ovary/peaks.HumanToMouse.HALPER.narrowPeak.gz"
b="/ocean/projects/bio230007p/ikaplow/MouseAtac/Ovary/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz"
out="ovary_intersect_human_peaks_to_mouse_coords_open.bed"
both_open="y"

# Human to mouse ovary intersection (open in human, closed in mouse)
# same $a and $b as directly above, but use the -v flag instead of -u
out="ovary_intersect_human_peaks_to_mouse_coords_mouseClosed.bed"
both_open="n"

# Mouse to human pancreas intersection (both open)
a="/jet/home/kwang18/output/hal/Mouse/Pancreas/peaks.MouseToHuman.HALPER.narrowPeak.gz"
b="/ocean/projects/bio230007p/ikaplow/HumanAtac/Pancreas/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz"
out="pancreas_intersect_mouse_peaks_to_human_coords_open.bed"
both_open="y"

# Mouse to human pancreas intersection (open in mouse, closed in human)
# same $a and $b as directly above, but use the -v flag instead of -u
out="pancreas_intersect_mouse_peaks_to_human_coords_humanClosed.bed"
both_open="n"

# Human to mouse pancreas intersection (both open)
a="/jet/home/kwang18/output/hal/Human/Pancreas/peaks.HumanToMouse.HALPER.narrowPeak.gz"
b="/ocean/projects/bio230007p/ikaplow/MouseAtac/Pancreas/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz"
out="pancreas_intersect_human_peaks_to_mouse_coords_open.bed"
both_open="y"

# Human to mouse pancreas intersection (open in human, closed in mouse)
# same $a and $b as directly above, but use the -v flag instead of -u
out="pancreas_intersect_human_peaks_to_mouse_coords_mouseClosed.bed"
both_open="n"


# Example runs:

# bash cross_species_bedtools_intersection.sh "/jet/home/kwang18/output/hal/Mouse/Ovary/peaks.MouseToHuman.HALPER.narrowPeak.gz" "/ocean/projects/bio230007p/ikaplow/HumanAtac/Ovary/peak/idr_reproducibility/idr.conservative_peak.narrowPeak.gz" "ovary_intersect_mouse_peaks_to_human_coords_open.bed" y
# bash cross_species_bedtools_intersection.sh "/jet/home/kwang18/output/hal/Mouse/Ovary/peaks.MouseToHuman.HALPER.narrowPeak.gz" "/ocean/projects/bio230007p/ikaplow/HumanAtac/Ovary/peak/idr_reproducibility/idr.conservative_peak.narrowPeak.gz" "ovary_intersect_mouse_peaks_to_human_coords_humanClosed.bed" n

# bash cross_species_bedtools_intersection.sh "/jet/home/kwang18/output/hal/Human/Ovary/peaks.HumanToMouse.HALPER.narrowPeak.gz" "/ocean/projects/bio230007p/ikaplow/MouseAtac/Ovary/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz" "ovary_intersect_human_peaks_to_mouse_coords_open.bed" y
# bash cross_species_bedtools_intersection.sh "/jet/home/kwang18/output/hal/Human/Ovary/peaks.HumanToMouse.HALPER.narrowPeak.gz" "/ocean/projects/bio230007p/ikaplow/MouseAtac/Ovary/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz" "ovary_intersect_human_peaks_to_mouse_coords_mouseClosed.bed" n

# bash cross_species_bedtools_intersection.sh "/jet/home/kwang18/output/hal/Mouse/Pancreas/peaks.MouseToHuman.HALPER.narrowPeak.gz" "/ocean/projects/bio230007p/ikaplow/HumanAtac/Pancreas/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz" "pancreas_intersect_mouse_peaks_to_human_coords_open.bed" y
# bash cross_species_bedtools_intersection.sh "/jet/home/kwang18/output/hal/Mouse/Pancreas/peaks.MouseToHuman.HALPER.narrowPeak.gz" "/ocean/projects/bio230007p/ikaplow/HumanAtac/Pancreas/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz" "pancreas_intersect_mouse_peaks_to_human_coords_humanClosed.bed" n

# bash cross_species_bedtools_intersection.sh "/jet/home/kwang18/output/hal/Human/Pancreas/peaks.HumanToMouse.HALPER.narrowPeak.gz" "/ocean/projects/bio230007p/ikaplow/MouseAtac/Pancreas/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz" "pancreas_intersect_human_peaks_to_mouse_coords_open.bed" y
# bash cross_species_bedtools_intersection.sh "/jet/home/kwang18/output/hal/Human/Pancreas/peaks.HumanToMouse.HALPER.narrowPeak.gz" "/ocean/projects/bio230007p/ikaplow/MouseAtac/Pancreas/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz" "pancreas_intersect_human_peaks_to_mouse_coords_mouseClosed.bed" n

