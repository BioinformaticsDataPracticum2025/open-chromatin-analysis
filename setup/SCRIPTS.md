# Scripts Documentation

This document provides detailed usage information for the scripts.

---

## bedtool.sh

This script offers a convenient way to perform multiple bedtools intersection analysis with user-customizable options. (Currently not up-to-date- run cross_species_bedtools_intersection.sh instead.)

### Usage
```bash
. bedtools.sh path_to_input_file
```

### Input File Format
The input file should be a tab-separated text file containing 5 columns. Below is an example file format:

**Example: `example_input.txt`**
```txt
# comment the line with #
file_path_to_peak_file_A     file_path_to_peak_file_B     bedfile_output_path     y     file_A_B

# second pair
file_path_to_peak_file_C     file_path_to_peak_file_D     bedfile_output_path     n     file_C_D
```
- **Column 4:** Reporting flag:  
 `y` corresponds to `-u` flag for bedtools, meaning unique overlap report   
 `n` corresponds to `-v` flag for bedtools, meaning non-overlap report
- **Column 5:** The label that will appear in the generated plot 


### Outputs
(tbd)

## cross_species_bedtools_intersection.sh

This script will eventually be merged into bedtool.sh. It takes two input BED files, outputs a bedtools intersection of these two files, and prints two metrics: the percentage overlap (number of lines in output intersection file divided by number of lines in the first input file) and the Jaccard overlap (a better metric to use than percentage if the two input files differ greatly in number of lines, as might be the case if intersecting conservative peaks with optimal peaks).

### Usage
```
bash cross_species_bedtools_intersection.sh $1 $2 $3 $4

# With example values:
bash cross_species_bedtools_intersection.sh "~/output/hal/Mouse/Ovary/peaks.MouseToHuman.HALPER.narrowPeak.gz" "$PROJECT/../ikaplow/HumanAtac/Ovary/peak/idr_reproducibility/idr.conservative_peak.narrowPeak.gz" "ovary_intersect_mouse_peaks_to_human_coords_open.bed" y

# $1 and $2 are input files to bedtools, $3 is the name of the output file,
# $4 specifies whether to look for regions that are open in both genomes ("y") or closed in the second genome ("n")

# Using CLIs:
a=$1
b=$2
out=$3
both_open=$4 # either "y" or "n"; will not take other values
```
(note: while you can specify a directory in the output filepath, this script currently doesn't check whether that directory already exists, and so you may run into errors if that happens. I suggest first making your desired output directory so that you don't encounter errors. We hope to implement that fix sometime.)

### Outputs
If $both_open == "y", writes bedtools intersect -a $a -b $b -u > $out. This is the set of unique overlaps between the first and second input files. If the input files contain open chromatin regions, then the output file represents peaks that occur in both input files.
If $both_open == "n", writes bedtools intersect -a $a -b $b -v > $out. This is the set of peaks that occur in the first but not the second input file. If the input files contain open chromatin regions, then the output file represents peaks that occur in $a but not $b.
