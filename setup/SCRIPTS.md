# Scripts Documentation

This document provides detailed usage information for the scripts.
Steps 1 and 4 are not included. Step 1 entails manual inspection of QC reports, while Step 4 is done using the [GREAT web tool](http://great.stanford.edu/public/html/).

---

# Step 2: map OCRs from the same tissues across species
## submit_hal.sh
Runs [halLiftover and HALPER](https://github.com/pfenninglab/halLiftover-postprocessing?tab=readme-ov-file#example-run-of-halper) on the input files.

### Dependencies
* [hal](https://github.com/pfenninglab/halLiftover-postprocessing?tab=readme-ov-file#example-run-of-halper)
* [Anaconda3](https://www.anaconda.com/docs/getting-started/anaconda/install)

### IMPORTANT NOTE
Refer to this block of code. Before you run submit_hal.sh on your own device, change these lines of code in submit_hal.sh.
```bash
# hal and HALPER; installation documentation says you have to set these manually, without ~
# IMPORTANT: if you are running this on your own device, change the paths to match your own paths to the hal and halLiftover repositories
# These lines are key to getting halLiftover to run.
export PATH=/jet/home/kwang18/repos/hal/bin:${PATH}
export PYTHONPATH=/jet/home/kwang18/repos/halLiftover-postprocessing:${PYTHONPATH}
```

### Usage
```bash
# Usage(){
#     echo "Usage: $0 -p <path_to_halper_script> -b <input_bed_file> -o <output_directory> -s <source_species> -t <target_species> -c <alignment_file>" 
#     exit 1
# }

help_str="
Parameters:
  -h, --help:     Print out the manual
  -d, --dir:      halLiftover-postprocessing directory    Optional parameter
  -b, --bed:      Input BED or narrowpeak file            Mandatory parameter
  -o, --output:   Output directory                        Optional parameter
  -s, --source:   Source species                          Mandatory parameter
  -t, --target:   Target species                          Mandatory parameter
  -c, --align:    Alignment File                          Optional parameter
"

# mouse pancreas (sbatch to run on the cluster):
# sbatch submit_hal.sh -b "/ocean/projects/bio230007p/ikaplow/MouseAtac/Pancreas/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz" -o ~/output/hal/Mouse/Pancreas -s Mouse -t Human
```

### Inputs
Refer to the help string under the "usage" heading.

### Outputs
Two halLiftover output files ending in .sFile.bed.gz and .tFile.bed.gz. Also a HALPER output file ending in .HALPER.narrowPeak.gz. The HALPER file is essentially a BED file in which the first three columns are the coordinates of the source species's gene in terms of the target species's coordinates (for every ortholog found between the two), the fourth column contains the original coordinates from the source species, and the rest of the columns can be ignored.
See [hal documentation](https://github.com/pfenninglab/halLiftover-postprocessing?tab=readme-ov-file#output-files-produced-by-halper) for more information.

Example:
peaks.MouseToHuman.HALPER.narrowPeak.gz  peaks.MouseToHuman.halLiftover.sFile.bed.gz  peaks.MouseToHuman.halLiftover.tFile.bed.gz

# Steps 2a and 3: find OCRs shared between different species (step 2a) or different tissues (step 3)
## bedtools.sh

This script offers a convenient way to perform multiple bedtools intersection analysis with user-customizable options.

### Dependencies
* [Anaconda3](https://www.anaconda.com/docs/getting-started/anaconda/install)
* [bedtools](https://anaconda.org/bioconda/bedtools) (can be conda installed)

### Usage
```bash
# Example usage:
# bash bedtools.sh ~/output/hal/Mouse/Ovary/peaks.MouseToHuman.HALPER.narrowPeak.gz $PROJECT/../ikaplow/HumanAtac/Ovary/peak/idr_reproducibility/idr.conservative_peak.narrowPeak.gz ~/input/test_bedtools.bed y testname
```

### Input:
There are 5 CLIs. Below is an example:

**Example: `example_input.txt`**
```txt
# take 5 CLIs as input:
# bash bedtools.sh file_A file_B output_file intersection_mode name

# For intersection_mode:
# y: open in both
# n: open in file_A, closed in file_B
```
- **CLI 4:** Reporting flag:  
 `y` corresponds to `-u` flag for bedtools, meaning unique overlap report   
 `n` corresponds to `-v` flag for bedtools, meaning non-overlap report
- **CLI 5:** The label that will appear in the generated plot 


### Outputs
* A bed file at bedfile_output_path (the 3rd item in the input txt file), containing intersected peaks between peak files A and B (which were the 1st and 2nd items in the input txt file).
  * If column 4 is "y", writes bedtools intersect -a $a -b $b -u > $out. This is the set of unique overlaps between the first and second input files. If the input files contain open chromatin regions, then the output file represents peaks that occur in both input files.
  * If column 4 is "n", writes bedtools intersect -a $a -b $b -v > $out. This is the set of peaks that occur in the first but not the second input file. If the input files contain open chromatin regions, then the output file represents peaks that occur in $a but not $b.
* Prints the ratio of lines in the output bed file to lines in input file A, as a percentage. This is not a very robust measure, especially if input files A and B differ greatly in size.
* Prints the [Jaccard](https://bedtools.readthedocs.io/en/latest/content/tools/jaccard.html) of input files A and B; a measurement that is robust to input file sizes.

## cross_species_bedtools_intersection.sh (deprecated)

This script will eventually be merged into bedtool.sh. It takes two input BED files, outputs a bedtools intersection of these two files, and prints two metrics: the percentage overlap (number of lines in output intersection file divided by number of lines in the first input file) and the Jaccard overlap (a better metric to use than percentage if the two input files differ greatly in number of lines, as might be the case if intersecting conservative peaks with optimal peaks).

### Dependencies
* [Anaconda3](https://www.anaconda.com/docs/getting-started/anaconda/install)
* [bedtools](https://anaconda.org/bioconda/bedtools) (can be conda installed)

### Usage
```bash
bash cross_species_bedtools_intersection.sh $1 $2 $3 $4

# With example values:
bash cross_species_bedtools_intersection.sh "~/output/hal/Mouse/Ovary/peaks.MouseToHuman.HALPER.narrowPeak.gz" "$PROJECT/../ikaplow/HumanAtac/Ovary/peak/idr_reproducibility/idr.conservative_peak.narrowPeak.gz" "ovary_intersect_mouse_peaks_to_human_coords_open.bed" y

# $1 and $2 are input files to bedtools (.gz format expected), $3 is the name of the output file,
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

# Step 5: identify promoters and enhancers
## (add step 5 script once it's done)

# Step 6: find motifs enriched in OCRs (particularly enhancers) from previously-processed datasets
## convert_bed_to_fasta.sh
Step 6 (motif analysis) requires FASTA input. Prior steps in the pipeline produce BED files, so it's necessary to run this on any files you intend to use in step 6. In particular, use this script to convert bed outputs from step 5 (enhancers and promoters) to FASTA.

### Inputs:
$1: $ref_fasta which is either h (human), m (mouse), or a filepath ending in .fasta. If the file is equivalent to FASTA but has a different file extension, rename it to end in .fasta.
$2: $input_bed which is a filepath to the BED file you want to convert to a FASTA
$3: $output_filename. If you want to put it in a new directory, please make the directory beforehand so that it exists.

### Output: a fasta file with the specified $output_filename, containing sequences at regions specified in $input_bed.

### Example run:
```bash
bash convert_bed_to_fasta.sh h ~/output/step3_bedtools/human_ovary_to_pancreas_intersect_pancreasClosed.bed ~/input/getfasta_test_output.fasta
# I chose to put the output FASTA file in the "input" dir because it'll be used for step 6 motif analysis
```

## motif_analysis.sh
After converting your input from bed to fasta using convert_bed_to_fasta.sh, you are ready to find motifs that are enriched in the input file.

### Inputs:
$1: $input fasta in which to find motifs.
$2: $outdir in which the results will be written. IMPORTANT NOTE ABOUT OUTDIR: provide a unique outdir each time, otherwise the results will be overwritten
$3: ref_db, which is either h, m, or a path to a file that ends in .meme. Throws an error otherwise.

#### Output: Look for the motifs and E-values in the summary.tsv file in $outdir.

### Example run:
```bash
sbatch ~/repos/open-chromatin-analysis/motif_analysis.sh ~/input/getfasta_test_output.fasta ~/output/meme_outdir_test h
# I recommend using sbatch because MEME-suite takes a long time to run (it could take 24 hours depending on the size of the input file)
```
