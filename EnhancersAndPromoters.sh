#!/bin/bash
module load bedtools

Project_directory=$HOME

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


# Find enhancers unique to pancreas or ovary within each species

# Human pancreas specific enhancers
bedtools intersect -a $Project_directory/output/humanPancreas_enhancers.bed -b $Project_directory/output/humanOvary_enhancers.bed -v > $Project_directory/output/humanPancreasOnly_enhancers.bed
# Human ovary specific enhancers
bedtools intersect -a $Project_directory/output/humanOvary_enhancers.bed -b $Project_directory/output/humanPancreas_enhancers.bed -v > $Project_directory/output/humanOvaryOnly_enhancers.bed
# Mouse pancreas specific enhancers
bedtools intersect -a $Project_directory/output/mousePancreas_enhancers.bed -b $Project_directory/output/mouseOvary_enhancers.bed -v > $Project_directory/output/mousePancreasOnly_enhancers.bed
# Mouse ovary specific enhancers
bedtools intersect -a $Project_directory/output/mouseOvary_enhancers.bed -b $Project_directory/output/mousePancreas_enhancers.bed -v > $Project_directory/output/mouseOvaryOnly_enhancers.bed


# Species specific enhancers for human vs mouse for each tissue

# Pancreas human-specific enhancers
bedtools intersect -a $Project_directory/output/humanPancreas_mouseCoordinates_enhancers.bed -b $Project_directory/output/mousePancreas_enhancers.bed -v > $Project_directory/output/humanOnly_pancreas_enhancers.bed
# Pancreas mouse-specific enhancers
bedtools intersect -a $Project_directory/output/mousePancreas_enhancers.bed -b $Project_directory/output/humanPancreas_mouseCoordinates_enhancers.bed -v > $Project_directory/output/mouseOnly_pancreas_enhancers.bed
# Ovary human-specific enhancers
bedtools intersect -a $Project_directory/output/humanOvary_mouseCoordinates_enhancers.bed -b $Project_directory/output/mouseOvary_enhancers.bed -v > $Project_directory/output/humanOnly_ovary_enhancers.bed
# Ovary mouse-specific enhancers
bedtools intersect -a $Project_directory/output/mouseOvary_enhancers.bed -b $Project_directory/output/humanOvary_mouseCoordinates_enhancers.bed -v > $Project_directory/output/mouseOnly_ovar_enhancers.bed



# % shared across tissues 

# Human promoters
bedtools intersect -a $Project_directory/output/humanPancreas_promoters.bed -b $Project_directory/output/humanOvary_promoters.bed -u > $Project_directory/output/human_crossTissue_promoters.bed
a=$(wc -l < $Project_directory/output/humanPancreas_promoters.bed)
b=$(wc -l < $Project_directory/output/humanOvary_promoters.bed)
avg=$(( (a + b) / 2 ))
count=$(wc -l < $Project_directory/output/human_crossTissue_promoters.bed)
echo "Human promoters shared across tissues: $count overlaps / avg $avg regions = $(awk "BEGIN { printf \"%.2f\", ($count/$avg)*100 }")%"

# Mouse promoters
bedtools intersect -a $Project_directory/output/mousePancreas_promoters.bed -b $Project_directory/output/mouseOvary_promoters.bed -u > $Project_directory/output/mouse_crossTissue_promoters.bed
a=$(wc -l < $Project_directory/output/mousePancreas_promoters.bed)
b=$(wc -l < $Project_directory/output/mouseOvary_promoters.bed)
avg=$(( (a + b) / 2 ))
count=$(wc -l < $Project_directory/output/mouse_crossTissue_promoters.bed)
echo "Mouse promoters shared across tissues: $count overlaps / avg $avg regions = $(awk "BEGIN { printf \"%.2f\", ($count/$avg)*100 }")%"

# Human enhancers
bedtools intersect -a $Project_directory/output/humanPancreas_enhancers.bed -b $Project_directory/output/humanOvary_enhancers.bed -u > $Project_directory/output/human_crossTissue_enhancers.bed
a=$(wc -l < $Project_directory/output/humanPancreas_enhancers.bed)
b=$(wc -l < $Project_directory/output/humanOvary_enhancers.bed)
avg=$(( (a + b) / 2 ))
count=$(wc -l < $Project_directory/output/human_crossTissue_enhancers.bed)
echo "Human enhancers shared across tissues: $count overlaps / avg $avg regions = $(awk "BEGIN { printf \"%.2f\", ($count/$avg)*100 }")%"

# Mouse enhancers
bedtools intersect -a $Project_directory/output/mousePancreas_enhancers.bed -b $Project_directory/output/mouseOvary_enhancers.bed -u > $Project_directory/output/mouse_crossTissue_enhancers.bed
a=$(wc -l < $Project_directory/output/mousePancreas_enhancers.bed)
b=$(wc -l < $Project_directory/output/mouseOvary_enhancers.bed)
avg=$(( (a + b) / 2 ))
count=$(wc -l < $Project_directory/output/mouse_crossTissue_enhancers.bed)
echo "Mouse enhancers shared across tissues: $count overlaps / avg $avg regions = $(awk "BEGIN { printf \"%.2f\", ($count/$avg)*100 }")%"

# TODO: add % (or Jaccard) shared across species
# Enhancers that are shared across species for each tissue
# Pancreas enhancers that appear in both species
bedtools intersect -a $Project_directory/output/humanPancreas_mouseCoordinates_enhancers.bed -b $Project_directory/output/mousePancreas_enhancers.bed -u > $Project_directory/output/bothSpecies_pancreas_enhancers.bed
# Ovary enhancers that appear in both species
bedtools intersect -a $Project_directory/output/humanOvary_mouseCoordinates_enhancers.bed -b $Project_directory/output/mouseOvary_enhancers.bed -u > $Project_directory/output/bothSpecies_ovary_enhancers.bed