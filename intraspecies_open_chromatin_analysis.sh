#!/bin/bash
# Intra Species cross tissue analysis 
# Description:
# This script compares open chromatin regions (ATAC-seq peaks) between ovary and pancreas tissues
# in human and mouse. It performs:
# * BEDTools-based intersection of peak regions to identify shared and tissue specific peaks
# * Calculates what percentage of peaks in one tissue overlap with peaks in the other 
# * Calculates how similar the two tissues are based on how much their regions overlap at the base-pair level (Jaccard index)
module load bedtools

Project_directory="/ocean/projects/bio230007p/asoni2"
Output_directory="${Project_directory}/open_chromatin_analysis"

# Create subdirectiories to save human and mouse outputs
mkdir -p "${Output_directory}/human"
mkdir -p "${Output_directory}/mouse"

#Unzip peak files and sort by genomic coordinate (sorting required by jaccard bedtools)
gunzip -c /ocean/projects/bio230007p/ikaplow/HumanAtac/Ovary/peak/idr_reproducibility/idr.conservative_peak.narrowPeak.gz | sort -k1,1 -k2,2n > human_ovary.bed
gunzip -c /ocean/projects/bio230007p/ikaplow/HumanAtac/Pancreas/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz | sort -k1,1 -k2,2n > human_pancreas.bed
gunzip -c /ocean/projects/bio230007p/ikaplow/MouseAtac/Ovary/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz | sort -k1,1 -k2,2n > mouse_ovary.bed
gunzip -c /ocean/projects/bio230007p/ikaplow/MouseAtac/Pancreas/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz | sort -k1,1 -k2,2n > mouse_pancreas.bed


# Human - Ovary first
#Output BED file: regions in ovary that also overlap pancreas
bedtools intersect -a human_ovary.bed -b human_pancreas.bed -u > "${Output_directory}/human/shared_regions_ovaryfirst.bed"
#Output BED file: open regions unique to ovary
bedtools intersect -a human_ovary.bed -b human_pancreas.bed -v > "${Output_directory}/human/ovaryonly_regions_ovaryfirst.bed"

# Human - Pancreas first
#Output BED file: regions in pancreas that also overlap ovary
bedtools intersect -a human_pancreas.bed -b human_ovary.bed -u > "${Output_directory}/human/shared_regions_pancreasfirst.bed"
#Output BED file: open regions unique to pancreas
bedtools intersect -a human_pancreas.bed -b human_ovary.bed -v > "${Output_directory}/human/pancreas_regions_only.bed"

# Mouse - Ovary first
#Output BED file: regions in ovary that also overlap pancreas
bedtools intersect -a mouse_ovary.bed -b mouse_pancreas.bed -u > "${Output_directory}/mouse/shared_regions_ovaryfirst.bed"
#Output BED file: open regions unique to ovary
bedtools intersect -a mouse_ovary.bed -b mouse_pancreas.bed -v > "${Output_directory}/mouse/ovaryonly_regions_ovaryfirst.bed"

# Mouse - Pancreas first
#Output BED file: regions in pancreas that also overlap ovary
bedtools intersect -a mouse_pancreas.bed -b mouse_ovary.bed -u > "${Output_directory}/mouse/shared_regions_pancreasfirst.bed"
#Output BED file: open regions unique to pancreas
bedtools intersect -a mouse_pancreas.bed -b mouse_ovary.bed -v > "${Output_directory}/mouse/pancreas_regions_only.bed"

#% of Open chromatin regions shared between tissues and % unique to tissues 
# Human Ovary
ovary_total=$(wc -l < human_ovary.bed)
ovary_not_shared=$(wc -l < "${Output_directory}/human/ovaryonly_regions_ovaryfirst.bed")
ovary_shared=$(wc -l < "${Output_directory}/human/shared_regions_ovaryfirst.bed")
ovary_percent=$(awk "BEGIN {printf \"%.4f\", ($ovary_shared / $ovary_total) * 100}")
ovary_percent_not_shared=$(awk "BEGIN {printf \"%.4f\", ($ovary_not_shared / $ovary_total) * 100}")
echo "Human Ovary: $ovary_shared out of $ovary_total regions shared (${ovary_percent}%)"
echo "Regions of human ovary not shared: $ovary_not_shared of $ovary_total regions (${ovary_percent_not_shared}%)"

# Human Pancreas
pancreas_total=$(wc -l < human_pancreas.bed)
pancreas_shared=$(wc -l < "${Output_directory}/human/shared_regions_pancreasfirst.bed")
pancreas_not_shared=$(wc -l < "${Output_directory}/human/pancreas_regions_only.bed")
pancreas_percent=$(awk "BEGIN {printf \"%.4f\", ($pancreas_shared / $pancreas_total) * 100}")
pancreas_percent_not_shared=$(awk "BEGIN {printf \"%.4f\", ($pancreas_not_shared / $pancreas_total) * 100}")
echo "Human Pancreas: $pancreas_shared out of $pancreas_total regions shared (${pancreas_percent}%)"
echo "Regions of human pancreas not shared: $pancreas_not_shared (${pancreas_percent_not_shared}%)"


# Mouse Ovary
mouse_ovary_total=$(wc -l < mouse_ovary.bed)
mouse_ovary_shared=$(wc -l < "${Output_directory}/mouse/shared_regions_ovaryfirst.bed")
mouse_ovary_not_shared=$(wc -l < "${Output_directory}/mouse/ovaryonly_regions_ovaryfirst.bed")
mouse_ovary_percent=$(awk "BEGIN {printf \"%.4f\", ($mouse_ovary_shared / $mouse_ovary_total) * 100}")
mouse_ovary_percent_not_shared=$(awk "BEGIN {printf \"%.4f\", ($mouse_ovary_not_shared / $mouse_ovary_total) * 100}")
echo "Mouse Ovary: $mouse_ovary_shared out of $mouse_ovary_total regions shared (${mouse_ovary_percent}%)"
echo "Regions of mouse ovary not shared: $mouse_ovary_not_shared (${mouse_ovary_percent_not_shared}%)"

#JACCARD METHOD:

# Base pair level similarity using Jaccard index; it is a symmetric metric 
# The output is saved to a txt file and printed as a percentage overlap (extracted from the third column of output)

# Human: Ovary vs Pancreas
bedtools jaccard -a human_ovary.bed -b human_pancreas.bed > "${Output_directory}/human/jaccard_ovary_vs_pancreas.txt"
jaccard1=$(tail -n 1 "${Output_directory}/human/jaccard_ovary_vs_pancreas.txt" | awk '{printf "%.4f", $3 * 100}')
echo "Human Ovary vs Pancreas Jaccard Overlap: ${jaccard1}%"

# Human: Pancreas vs Ovary
bedtools jaccard -a human_pancreas.bed -b human_ovary.bed > "${Output_directory}/human/jaccard_pancreas_vs_ovary.txt"
jaccard2=$(tail -n 1 "${Output_directory}/human/jaccard_pancreas_vs_ovary.txt" | awk '{printf "%.4f", $3 * 100}')
echo "Human Pancreas vs Ovary Jaccard Overlap: ${jaccard2}%"

# Mouse: Ovary vs Pancreas
bedtools jaccard -a mouse_ovary.bed -b mouse_pancreas.bed > "${Output_directory}/mouse/jaccard_ovary_vs_pancreas.txt"
jaccard3=$(tail -n 1 "${Output_directory}/mouse/jaccard_ovary_vs_pancreas.txt" | awk '{printf "%.4f", $3 * 100}')
echo "Mouse Ovary vs Pancreas Jaccard Overlap: ${jaccard3}%"

# Mouse: Pancreas vs Ovary
bedtools jaccard -a mouse_pancreas.bed -b mouse_ovary.bed > "${Output_directory}/mouse/jaccard_pancreas_vs_ovary.txt"
jaccard4=$(tail -n 1 "${Output_directory}/mouse/jaccard_pancreas_vs_ovary.txt" | awk '{printf "%.4f", $3 * 100}')
echo "Mouse Pancreas vs Ovary Jaccard Overlap: ${jaccard4}%"




