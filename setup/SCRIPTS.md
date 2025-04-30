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
Refer to the help string under the "usage" heading. The BED/narrowPeak file should be processed through the [ENCODE ATAC-seq](https://github.com/ENCODE-DCC/atac-seq-pipeline/tree/master) pipeline. The alignment file is a Cactus alignment. The source species is the species that matches your input dataset's species, and the target species is the one whose genome coordinates you need to convert your input data to in order to map orthologs. Make sure to spell your source and target species exactly as they are spelled in the Cactus alignment.

### Outputs
Two halLiftover output files ending in .sFile.bed.gz and .tFile.bed.gz. Also a HALPER output file ending in .HALPER.narrowPeak.gz. The HALPER file is essentially a BED file in which the first three columns are the coordinates of the source species's gene in terms of the target species's coordinates (for every ortholog found between the two), the fourth column contains the original coordinates from the source species, and the rest of the columns can be ignored.
See [hal documentation](https://github.com/pfenninglab/halLiftover-postprocessing?tab=readme-ov-file#output-files-produced-by-halper) for more information.

Example:
peaks.MouseToHuman.HALPER.narrowPeak.gz  peaks.MouseToHuman.halLiftover.sFile.bed.gz  peaks.MouseToHuman.halLiftover.tFile.bed.gz

# Steps 2a and 3: find OCRs shared between different species (step 2a) or different tissues (step 3)
## bedtools.sh

This script provides a streamlined Bedtools wrapper that automatically decompresses and sorts two gzipped peak files, performs either intersection (common intervals) or subtraction (unique to file A) based on a user‐specified mode, and then computes and reports overlap statistics (percentage retained and Jaccard index).

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
* An output file with name provided as CLI 5.

# Step 5: split an ENCODE cCREs file into promoters and enhancers
## split_encode_ccres.sh
The purpose of this script is to split an ENCODE cCREs file into promoters and enhancers. For your convenience, we've provided mouse and human cCREs that have already been split- refer to the [input directory](https://github.com/BioinformaticsDataPracticum2025/open-chromatin-analysis/tree/main/input).  
However, if you are studying a different species, you can use this script to split the corresponding ENCODE cCREs file. You must follow the instructions below on how to download the ENCODE cCREs file in order to ensure that it is in the correct format.

### Instructions on how to download the input:
split_encode_ccres.sh expects an ENCODE cCREs BED file downloaded from the UCSC Table Browser https://genome.ucsc.edu/cgi-bin/hgTables . Under the "Retrieve and display data" menu, select the "Output format" of "Selected fields from primary and related tables", enter a filename so that it downloads instead of opening in the browser, choose tsv format, and gzip it. Click "Get output", and on the next page, select the following four columns: chrom, chromStart, chromEnd, and ucscLabel. The first three columns are the contents of a typical BED file, while the fourth column is comprised of "prom", "enhD", or "enhP" which are the annotations that will be used to separate the entries into promoters ("prom") and enhancers (everything else). **IMPORTANT:** This script is not built to work with any fourth column that is not ucscLabel.

Input: a gzipped BED file with the format described above
```bash
# Example run:
bash split_encode_ccres.sh "${HOME}/input/ENCODE_cCREs_human.txt.gz"
```
Output: two files, one containing the promoters and one containing the enhancers. The script will print their filenames.

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

#### Output: 
Look for the motifs and E-values in the summary.tsv file in $outdir. Refer to meme-chip.html (which provides logo diagrams) and summary.tsv.

### Example run:
```bash
sbatch ~/repos/open-chromatin-analysis/motif_analysis.sh ~/input/getfasta_test_output.fasta ~/output/meme_outdir_test h
# I recommend using sbatch because MEME-suite takes a long time to run (it could take 24 hours depending on the size of the input file)
```
