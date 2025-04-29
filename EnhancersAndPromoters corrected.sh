#!/bin/bash
module load bedtools

Project_directory="/ocean/projects/bio230007p/asoni2"

gunzip -k "$Project_directory/input/ENCODE_cCREs_human.txt.gz"
gunzip -k "$Project_directory/input/ENCODE_cCREs_mouse.txt.gz"

# SPLIT ENCODE FILES — HUMAN
awk '$4 == "prom"' $Project_directory/input/ENCODE_cCREs_human.txt > $Project_directory/input/promoters_human.txt
awk '$4 == "enhD" || $4 == "enhP"' $Project_directory/input/ENCODE_cCREs_human.txt > $Project_directory/input/enhancers_human.txt

# SPLIT ENCODE FILES — MOUSE
awk '$4 == "prom"' $Project_directory/input/ENCODE_cCREs_mouse.txt > $Project_directory/input/promoters_mouse.txt
awk '$4 == "enhD" || $4 == "enhP"' $Project_directory/input/ENCODE_cCREs_mouse.txt > $Project_directory/input/enhancers_mouse.txt

# ATAC-seq peaks - promoters
bedtools intersect -a $Project_directory/input/human_pancreas.bed -b $Project_directory/input/promoters_human.txt -u > $Project_directory/output/humanPancreas_promoters.bed
bedtools intersect -a $Project_directory/input/human_ovary.bed -b $Project_directory/input/promoters_human.txt -u > $Project_directory/output/humanOvary_promoters.bed
bedtools intersect -a $Project_directory/input/mousePancreas.narrowPeak -b $Project_directory/input/promoters_mouse.txt -u > $Project_directory/output/mousePancreas_promoters.bed
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

# % shared

# Human promoters
bedtools intersect -a $Project_directory/output/humanPancreas_promoters.bed -b $Project_directory/output/humanOvary_promoters.bed -u > $Project_directory/output/human_crossTissue_promoters.bed
count=$(wc -l < $Project_directory/output/human_crossTissue_promoters.bed)
a=$(wc -l < $Project_directory/output/humanPancreas_promoters.bed)
b=$(wc -l < $Project_directory/output/humanOvary_promoters.bed)
avg=$(( (a + b) / 2 ))
echo "Human promoters shared across tissues: $count / $avg = $(awk "BEGIN { printf \"%.2f\", ($count/$avg)*100 }")%"

# Mouse promoters
bedtools intersect -a $Project_directory/output/mousePancreas_promoters.bed -b $Project_directory/output/mouseOvary_promoters.bed -u > $Project_directory/output/mouse_crossTissue_promoters.bed
count=$(wc -l < $Project_directory/output/mouse_crossTissue_promoters.bed)
a=$(wc -l < $Project_directory/output/mousePancreas_promoters.bed)
b=$(wc -l < $Project_directory/output/mouseOvary_promoters.bed)
avg=$(( (a + b) / 2 ))
echo "Mouse promoters shared across tissues: $count / $avg = $(awk "BEGIN { printf \"%.2f\", ($count/$avg)*100 }")%"

# Human enhancers
bedtools intersect -a $Project_directory/output/humanPancreas_enhancers.bed -b $Project_directory/output/humanOvary_enhancers.bed -u > $Project_directory/output/human_crossTissue_enhancers.bed
count=$(wc -l < $Project_directory/output/human_crossTissue_enhancers.bed)
a=$(wc -l < $Project_directory/output/humanPancreas_enhancers.bed)
b=$(wc -l < $Project_directory/output/humanOvary_enhancers.bed)
avg=$(( (a + b) / 2 ))
echo "Human enhancers shared across tissues: $count / $avg = $(awk "BEGIN { printf \"%.2f\", ($count/$avg)*100 }")%"