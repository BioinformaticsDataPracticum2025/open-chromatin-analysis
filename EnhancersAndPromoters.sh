#!/bin/bash
module load bedtools

Project_directory="/ocean/projects/bio230007p/asoni2"

gunzip -k "$Project_directory/input/ENCODE_cCREs_human.txt.gz"
gunzip -k "$Project_directory/input/ENCODE_cCREs_mouse.txt.gz"

#SPLIT ENCODE FILES
awk '$4 == "prom"' $Project_directory/input/ENCODE_cCREs_human.txt > $Project_directory/input/promoters_human.txt
awk '$4 != "prom"' $Project_directory/input/ENCODE_cCREs_human.txt > $Project_directory/input/enhancers_human.txt
awk '$4 == "prom"' $Project_directory/input/ENCODE_cCREs_mouse.txt > $Project_directory/input/promoters_mouse.txt
awk '$4 != "prom"' $Project_directory/input/ENCODE_cCREs_mouse.txt > $Project_directory/input/enhancers_mouse.txt

# ATAC-seq peaks - promoters
bedtools intersect -a $Project_directory/input/humanPancreas.narrowPeak -b $Project_directory/input/promoters_human.txt -u > $Project_directory/output/humanPancreas_promoters.bed
bedtools intersect -a $Project_directory/input/humanOvary.narrowPeak -b $Project_directory/input/promoters_human.txt -u > $Project_directory/output/humanOvary_promoters.bed
bedtools intersect -a $Project_directory/input/mousePancreas.narrowPeak -b $Project_directory/input/promoters_mouse.txt -u > $Project_directory/output/mousePancreas_promoters.bed
bedtools intersect -a $Project_directory/input/mouseOvary.narrowPeak -b $Project_directory/input/promoters_mouse.txt -u > $Project_directory/output/mouseOvary_promoters.bed

# ATAC-seq peaks - enhancers 
bedtools intersect -a $Project_directory/input/humanPancreas.narrowPeak -b $Project_directory/input/enhancers_human.txt -u > $Project_directory/output/humanPancreas_enhancers.bed
bedtools intersect -a $Project_directory/input/humanOvary.narrowPeak -b $Project_directory/input/enhancers_human.txt -u > $Project_directory/output/humanOvary_enhancers.bed
bedtools intersect -a $Project_directory/input/mousePancreas.narrowPeak -b $Project_directory/input/enhancers_mouse.txt -u > $Project_directory/output/mousePancreas_enhancers.bed
bedtools intersect -a $Project_directory/input/mouseOvary.narrowPeak -b $Project_directory/input/enhancers_mouse.txt -u > $Project_directory/output/mouseOvary_enhancers.bed

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

