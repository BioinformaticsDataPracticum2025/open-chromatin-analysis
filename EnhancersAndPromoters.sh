#!/bin/bash

Project_directory=add 
# SPLIT ENCODE FILES — HUMAN
awk '$4 == "prom"' $Project_directory/input/ENCODE_cCREs_human.txt > $Project_directory/input/promoters_human.txt
awk '$4 == "enhD" || $4 == "enhP"' $Project_directory/input/ENCODE_cCREs_human.txt > $Project_directory/input/enhancers_human.txt

# SPLIT ENCODE FILES — MOUSE
awk '$4 == "prom"' $Project_directory/input/ENCODE_cCREs_mouse.txt > $Project_directory/input/promoters_mouse.txt
awk '$4 == "enhD" || $4 == "enhP"' $Project_directory/input/ENCODE_cCREs_mouse.txt > $Project_directory/input/enhancers_mouse.txt

# ATAC-seq peaks - promoters
bedtools intersect -a $Project_directory/input/human_pancreas.bed -b $Project_directory/input/promoters_human.txt -u > $Project_directory/output/humanPancreas_promoters.bed
bedtools intersect -a $Project_directory/input/human_ovary.bed -b $Project_directory/input/promoters_human.txt -u > $Project_directory/output/humanOvary_promoters.bed
bedtools intersect -a $Project_directory/input/mouse_pancreas.bed -b $Project_directory/input/promoters_mouse.txt -u > $Project_directory/output/mousePancreas_promoters.bed
bedtools intersect -a $Project_directory/input/mouse_ovary.bed -b $Project_directory/input/promoters_mouse.txt -u > $Project_directory/output/mouseOvary_promoters.bed

# ATAC-seq peaks - enhancers 
bedtools intersect -a $Project_directory/input/human_pancreas.bed -b $Project_directory/input/enhancers_human.txt -u > $Project_directory/output/humanPancreas_enhancers.bed
bedtools intersect -a $Project_directory/input/human_ovary.bed -b $Project_directory/input/enhancers_human.txt -u > $Project_directory/output/humanOvary_enhancers.bed
bedtools intersect -a $Project_directory/input/mouse_pancreas.bed -b $Project_directory/input/enhancers_mouse.txt -u > $Project_directory/output/mousePancreas_enhancers.bed
bedtools intersect -a $Project_directory/input/mouse_ovary.bed -b $Project_directory/input/enhancers_mouse.txt -u > $Project_directory/output/mouseOvary_enhancers.bed

# HALPER peaks - promoters 
bedtools intersect -a $Project_directory/input/humanPancreas.HumanToMouse.HALPER.narrowPeak -b $Project_directory/input/promoters_mouse.txt -u > $Project_directory/output/humanPancreas_mouseCoordinates_promoters.bed
bedtools intersect -a $Project_directory/input/humanOvary.HumanToMouse.HALPER.narrowPeak -b $Project_directory/input/promoters_mouse.txt -u > $Project_directory/output/humanOvary_mouseCoordinates_promoters.bed
bedtools intersect -a $Project_directory/input/mousePancreas.MouseToHuman.HALPER.narrowPeak -b $Project_directory/input/promoters_human.txt -u > $Project_directory/output/mousePancreas_humanCoordinates_promoters.bed
bedtools intersect -a $Project_directory/input/mouseOvary.MouseToHuman.HALPER.narrowPeak -b $Project_directory/input/promoters_human.txt -u > $Project_directory/output/mouseOvary_humanCoordinates_promoters.bed

#  HALPER peaks - enhancers
bedtools intersect -a $Project_directory/input/humanPancreas.HumanToMouse.HALPER.narrowPeak -b $Project_directory/input/enhancers_mouse.txt -u > $Project_directory/output/humanPancreas_mouseCoordinates_enhancers.bed
bedtools intersect -a $Project_directory/input/humanOvary.HumanToMouse.HALPER.narrowPeak -b $Project_directory/input/enhancers_mouse.txt -u > $Project_directory/output/humanOvary_mouseCoordinates_enhancers.bed
bedtools intersect -a $Project_directory/input/mousePancreas.MouseToHuman.HALPER.narrowPeak -b $Project_directory/input/enhancers_human.txt -u > $Project_directory/output/mousePancreas_humanCoordinates_enhancers.bed
bedtools intersect -a $Project_directory/input/mouseOvary.MouseToHuman.HALPER.narrowPeak -b $Project_directory/input/enhancers_human.txt -u > $Project_directory/output/mouseOvary_humanCoordinates_enhancers.bed

## JACCARD INDEX ACROSS TISSUES

# Human promoters
sort -k1,1 -k2,2n $Project_directory/output/humanPancreas_promoters.bed > $Project_directory/output/humanPancreas_promoters.bed.sorted
sort -k1,1 -k2,2n $Project_directory/output/humanOvary_promoters.bed > $Project_directory/output/humanOvary_promoters.bed.sorted
bedtools jaccard -a $Project_directory/output/humanPancreas_promoters.bed.sorted -b $Project_directory/output/humanOvary_promoters.bed.sorted > $Project_directory/output/jaccard_human_promoters.txt
jaccard_human_promoters=$(tail -n 1 "$Project_directory/output/jaccard_human_promoters.txt" | awk '{printf "%.4f", $3 * 100}')
echo "Human promoter Jaccard overlap across tissues: $jaccard_human_promoters"

# Mouse promoters
sort -k1,1 -k2,2n $Project_directory/output/mousePancreas_promoters.bed > $Project_directory/output/mousePancreas_promoters.bed.sorted
sort -k1,1 -k2,2n $Project_directory/output/mouseOvary_promoters.bed > $Project_directory/output/mouseOvary_promoters.bed.sorted
bedtools jaccard -a $Project_directory/output/mousePancreas_promoters.bed.sorted -b $Project_directory/output/mouseOvary_promoters.bed.sorted > $Project_directory/output/jaccard_mouse_promoters.txt
jaccard_mouse_promoters=$(tail -n 1 "$Project_directory/output/jaccard_mouse_promoters.txt" | awk '{printf "%.4f", $3 * 100}')
echo "Mouse promoter Jaccard overlap across tissues: $jaccard_mouse_promoters"

# Human enhancers
sort -k1,1 -k2,2n $Project_directory/output/humanPancreas_enhancers.bed > $Project_directory/output/humanPancreas_enhancers.bed.sorted
sort -k1,1 -k2,2n $Project_directory/output/humanOvary_enhancers.bed > $Project_directory/output/humanOvary_enhancers.bed.sorted
bedtools jaccard -a $Project_directory/output/humanPancreas_enhancers.bed.sorted -b $Project_directory/output/humanOvary_enhancers.bed.sorted > $Project_directory/output/jaccard_human_enhancers.txt
jaccard_human_enhancers=$(tail -n 1 "$Project_directory/output/jaccard_human_enhancers.txt" | awk '{printf "%.4f", $3 * 100}')
echo "Human enhancer Jaccard overlap across tissues: $jaccard_human_enhancers"

# Mouse enhancers
sort -k1,1 -k2,2n $Project_directory/output/mousePancreas_enhancers.bed > $Project_directory/output/mousePancreas_enhancers.bed.sorted
sort -k1,1 -k2,2n $Project_directory/output/mouseOvary_enhancers.bed > $Project_directory/output/mouseOvary_enhancers.bed.sorted
bedtools jaccard -a $Project_directory/output/mousePancreas_enhancers.bed.sorted -b $Project_directory/output/mouseOvary_enhancers.bed.sorted > $Project_directory/output/jaccard_mouse_enhancers.txt
jaccard_mouse_enhancers=$(tail -n 1 "$Project_directory/output/jaccard_mouse_enhancers.txt" | awk '{printf "%.4f", $3 * 100}')
echo "Mouse enhancer Jaccard overlap across tissues: $jaccard_mouse_enhancers"

#  % (or Jaccard) shared across species
# Enhancers that are shared across species for each tissue
# Pancreas enhancers that appear in both species
bedtools intersect -a $Project_directory/output/humanPancreas_mouseCoordinates_enhancers.bed -b $Project_directory/output/mousePancreas_enhancers.bed -u > $Project_directory/output/bothSpecies_pancreas_enhancers.bed
# Ovary enhancers that appear in both species
bedtools intersect -a $Project_directory/output/humanOvary_mouseCoordinates_enhancers.bed -b $Project_directory/output/mouseOvary_enhancers.bed -u > $Project_directory/output/bothSpecies_ovary_enhancers.bed
# Sort files for Jaccard analysis
sort -k1,1 -k2,2n $Project_directory/output/humanPancreas_mouseCoordinates_enhancers.bed > $Project_directory/output/humanPancreas_mouseCoordinates_enhancers.bed.sorted
sort -k1,1 -k2,2n $Project_directory/output/mousePancreas_enhancers.bed > $Project_directory/output/mousePancreas_enhancers.bed.sorted
sort -k1,1 -k2,2n $Project_directory/output/humanOvary_mouseCoordinates_enhancers.bed > $Project_directory/output/humanOvary_mouseCoordinates_enhancers.bed.sorted
sort -k1,1 -k2,2n $Project_directory/output/mouseOvary_enhancers.bed > $Project_directory/output/mouseOvary_enhancers.bed.sorted

# Pancreas enhancer Jaccard (human to mouse mapping)
bedtools jaccard -a $Project_directory/output/humanPancreas_mouseCoordinates_enhancers.bed.sorted -b $Project_directory/output/mousePancreas_enhancers.bed.sorted > $Project_directory/output/jaccard_pancreas_enhancers.txt
jaccard_pancreas=$(tail -n 1 "$Project_directory/output/jaccard_pancreas_enhancers.txt" | awk '{print $3}')
jaccard_pancreas_percent=$(tail -n 1 "$Project_directory/output/jaccard_pancreas_enhancers.txt" | awk '{printf "%.4f", $3 * 100}')
echo "Pancreas enhancer Jaccard overlap across species: $jaccard_pancreas_percent"
# Ovary enhancer Jaccard (human to mouse mapping)
bedtools jaccard -a $Project_directory/output/humanOvary_mouseCoordinates_enhancers.bed.sorted -b $Project_directory/output/mouseOvary_enhancers.bed.sorted > $Project_directory/output/jaccard_ovary_enhancers.txt
jaccard_ovary=$(tail -n 1 "$Project_directory/output/jaccard_ovary_enhancers.txt" | awk '{print $3}')
jaccard_ovary_percent=$(tail -n 1 "$Project_directory/output/jaccard_ovary_enhancers.txt" | awk '{printf "%.4f", $3 * 100}')
echo "Ovary enhancer Jaccard overlap across species: $jaccard_ovary_percent"