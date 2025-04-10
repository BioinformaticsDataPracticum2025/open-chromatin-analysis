#!/bin/bash
# Intra Species cross tissue analysis 
# This script performs open chromatin region comparisons between ovary and pancreas within human and mouse using ATAC seq peaks using bedtools
# It identifies shared regions between ovary and pancreas tissues and tissue specific open chromatin regions

module load bedtools

Project_directory="/ocean/projects/bio230007p/asoni2"
Output_directory="${Project_directory}/open_chromatin_analysis"

# Create output folders
mkdir -p "${Output_directory}/human"
mkdir -p "${Output_directory}/mouse"

#Unzip peak files
gunzip -c /ocean/projects/bio230007p/ikaplow/HumanAtac/Ovary/peak/idr_reproducibility/idr.conservative_peak.narrowPeak.gz > human_ovary.bed
gunzip -c /ocean/projects/bio230007p/ikaplow/HumanAtac/Pancreas/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz > human_pancreas.bed
gunzip -c /ocean/projects/bio230007p/ikaplow/MouseAtac/Ovary/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz > mouse_ovary.bed
gunzip -c /ocean/projects/bio230007p/ikaplow/MouseAtac/Pancreas/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz > mouse_pancreas.bed

# Human - Ovary first
# Shared regions open in both tissues
bedtools intersect -a human_ovary.bed -b human_pancreas.bed > "${Output_directory}/human/shared_regions_ovaryfirst.bed"
# Regions open in ovary only
bedtools intersect -a human_ovary.bed -b human_pancreas.bed -v > "${Output_directory}/human/ovaryonly_regions_ovaryfirst.bed"

# Human - Pancreas first
# Shared regions open in both tissues
bedtools intersect -a human_pancreas.bed -b human_ovary.bed > "${Output_directory}/human/shared_regions_pancreasfirst.bed"
# Regions open in pancreas only
bedtools intersect -a human_pancreas.bed -b human_ovary.bed -v > "${Output_directory}/human/pancreas_regions_only.bed"

# Mouse - Ovary first
# Shared regions open in both tissues
bedtools intersect -a mouse_ovary.bed -b mouse_pancreas.bed > "${Output_directory}/mouse/shared_regions_ovaryfirst.bed"
# Regions open in ovary only
bedtools intersect -a mouse_ovary.bed -b mouse_pancreas.bed -v > "${Output_directory}/mouse/ovaryonly_regions_ovaryfirst.bed"

# Mouse - Pancreas first
# Shared regions open in both tissues
bedtools intersect -a mouse_pancreas.bed -b mouse_ovary.bed > "${Output_directory}/mouse/shared_regions_pancreasfirst.bed"
# Regions open in pancreas only
bedtools intersect -a mouse_pancreas.bed -b mouse_ovary.bed -v > "${Output_directory}/mouse/pancreas_regions_only.bed"



