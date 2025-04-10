#!/bin/bash
# Intra Species cross tissue analysis 
# This script performs open chromatin region comparisons between ovary and pancreas within human and mouse using ATAC seq peaks using bedtools
# It identifies shared regions between ovary and pancreas tissues and tissue specific open chromatin regions

module load bedtools

Project_directory="/ocean/projects/bio230007p/asoni2"
Output_directory="${Project_directory}/open_chromatin_analysis"

# Create subdirectiories to save human and mouse outputs
mkdir -p "${Output_directory}/human"
mkdir -p "${Output_directory}/mouse"

#Unzip peak files and sort by genomic coordinate
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
bedtools intersect -a mouse_pancreas.bed -b mouse_ovary.bed > "${Output_directory}/mouse/shared_regions_pancreasfirst.bed"
#Output BED file: open regions unique to pancreas
bedtools intersect -a mouse_pancreas.bed -b mouse_ovary.bed -v > "${Output_directory}/mouse/pancreas_regions_only.bed"



