#!/bin/bash
#Intra Species tissue analysis 
module load bedtools

Project_directory="/ocean/projects/bio230007p/asoni2"
Output_directory="${Project_directory}/open_chromatin_analysis"

mkdir -p "${Output_directory}/human"
mkdir -p "${Output_directory}/mouse"

gunzip -c /ocean/projects/bio230007p/ikaplow/HumanAtac/Ovary/peak/idr_reproducibility/idr.conservative_peak.narrowPeak.gz > human_ovary.bed
gunzip -c /ocean/projects/bio230007p/ikaplow/HumanAtac/Pancreas/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz > human_pancreas.bed
gunzip -c /ocean/projects/bio230007p/ikaplow/MouseAtac/Ovary/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz > mouse_ovary.bed
gunzip -c /ocean/projects/bio230007p/ikaplow/MouseAtac/Pancreas/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz > mouse_pancreas.bed

# Human - Ovary first
bedtools intersect -a human_ovary.bed -b human_pancreas.bed > "${Output_directory}/human/shared_regions_ovaryfirst.bed"
bedtools intersect -a human_ovary.bed -b human_pancreas.bed -v > "${Output_directory}/human/ovaryonly_regions_ovaryfirst.bed"

# Human - Pancreas first
bedtools intersect -a human_pancreas.bed -b human_ovary.bed > "${Output_directory}/human/shared_regions_pancreasfirst.bed"
bedtools intersect -a human_pancreas.bed -b human_ovary.bed -v > "${Output_directory}/human/pancreas_regions_only.bed"

# Mouse - Ovary first
bedtools intersect -a mouse_ovary.bed -b mouse_pancreas.bed > "${Output_directory}/mouse/shared_regions_ovaryfirst.bed"
bedtools intersect -a mouse_ovary.bed -b mouse_pancreas.bed -v > "${Output_directory}/mouse/ovaryonly_regions_ovaryfirst.bed"

# Mouse - Pancreas first
bedtools intersect -a mouse_pancreas.bed -b mouse_ovary.bed > "${Output_directory}/mouse/shared_regions_pancreasfirst.bed"
bedtools intersect -a mouse_pancreas.bed -b mouse_ovary.bed -v > "${Output_directory}/mouse/pancreas_regions_only.bed"



