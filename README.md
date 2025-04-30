# Open Chromatin Analysis Pipline

## Table of Contents

- [Introduction](#introduction)

- [Requirements & Installation](#required-packages--tools)

- [Scripts](#scripts)

- [Usage](#usage)


---

## Introduction
This project explores the conservation and functional significance of open chromatin regions across human and mouse tissues, such as the ovary and pancreas. Open chromatin regions play a crucial role in regulating gene expression by providing access to transcriptional machinery. These open chromatin regions may be promoters or enhancers. Refer to the project description [here](https://github.com/BioinformaticsDataPracticum2025/open-chromatin-analysis/blob/main/03-713-ProjectDescription-2025.pdf).  
This pipeline could generally be used to conduct differential regulatory analysis between two different conditions in  bulk ATAC-seq data, e.g. between species and tissues. 

Our goals are to:  
1. Evaluate the quality of chromatin accessibility datasets (manual inspection of ATAC-seq QC reports).
2. Identify open chromatin regions that map across species and tissues (halLiftover, HALPER).
3. Compare the percentages of open chromatin regions that are conserved between species and between tissues (bedtools intersection between ATAC-seq peaks for same-species comparison, and between halLiftover and HALPER outputs for cross-species comparison).
4. Predict functions of regulatory regions (GREAT gene ontology analysis; manual web upload).
5. Analyze conserved regulatory elements such as enhancers and promoters (bedtools intersection with ENCODE CCREs).
6. Investigate associated biological processes and transcription factor binding sites (MEME and STREME outputs from MEME-ChIP).

---

## Required Packages & Tools
To run the analyses and workflows in this project, the following packages and tools are required. Initial setup is available [here](setup/README.md). 

- [Anaconda3](https://www.anaconda.com/docs/getting-started/anaconda/install) 2024.10-1 for conda installation and Python
- [bedtools](https://anaconda.org/bioconda/bedtools) v2.30.0 (can be conda installed)
- **[halLiftover and HALPER](https://github.com/pfenninglab/halLiftover-postprocessing.git)**, March 2025 version
- [GREAT](http://great.stanford.edu/public/html/) (please make sure that your input BED files have been cut to columns 1-3)
```bash
cut -f1-3 input_bed_file  > output_file_name 
# This keeps only the first 3 columns of the file.
```
- MEME-ChIP from [MEMEsuite](https://meme-suite.org/meme/doc/install.html) v5.4.1, or you may choose to use the web version of [MEME-ChIP](https://meme-suite.org/meme/tools/meme-chip) instead, commenting out the step 6 section of main.sh. In our installation, CentriMo was non-functional, so our analysis is limited to the MEME and STREME outputs.

### IMPORTANT NOTE REGARDING HAL
**IMPORTANT:** refer to the "important note" heading in the markdown linked [here](setup/SCRIPTS.md). You will need to change a few lines of code in order to get submit_hal to run on your own device; according to [hal setup documentation](https://github.com/pfenninglab/halLiftover-postprocessing/blob/master/hal_install_instructions.md), the paths must be hardcoded without use of "~". This unfortunately means that these lines must be hard-coded.  

## Usage
First, run your ATAC-seq narrowPeak files through the [ENCODE ATAC-seq pipeline](https://github.com/ENCODE-DCC/atac-seq-pipeline/tree/master), and inspect the html QC reports that it generates. These will be the four input datasets representing two species and two tissues. 
### Integrated script: main.sh
main.sh prompts the user for inputs. If you mistype something, use Ctrl+C to stop the program so that you can start over.  
#### Example inputs
Here is a set of example inputs to paste line by line into the console, when prompted to do so by main.sh. The prompts will take inputs that are used in steps 2, 5, and 6.  
Output directory (you may refer to a copy of this directory from our repository):
```text
test_output
```
Note that the output directory is placed in $HOME.  

Step 2 inputs:  
Cactus alignment file (not included in our repository due to size concerns):
```text
/ocean/projects/bio230007p/ikaplow/Alignments/10plusway-master.hal
```
Species 1 (exactly as written in the Cactus alignment file):
```text
Human
```
Species 2 (exactly as written in the Cactus alignment file):
```text
Mouse
```
Tissue 1:
```text
Pancreas
```
Tissue 2:
```text
Ovary
```

The following files are not included in our repository due to their large size, but if you have access to the ikaplow directory, you can use these paths. These are the ATAC-seq peak (i.e. open chromatin regions) files that you have selected after performing QC for step 1.  
Species 1, tissue 1:
```text
/ocean/projects/bio230007p/ikaplow/HumanAtac/Pancreas/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz
```
Species 1, tissue 2:
```text
/ocean/projects/bio230007p/ikaplow/HumanAtac/Ovary/peak/idr_reproducibility/idr.conservative_peak.narrowPeak.gz
```
Species 2, tissue 1:
```text
/ocean/projects/bio230007p/ikaplow/MouseAtac/Pancreas/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz
```
Species 2, tissue 2:
```text
/ocean/projects/bio230007p/ikaplow/MouseAtac/Ovary/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz
```


Step 5 inputs:  
To split the open chromatin regions from the step 2 inputs into enhancers and promoters, we intersect them with BED files that contain enhancers and promoters. For the following enhancers and promoters BED files, you can either use our pre-split files for human and mouse (included in the input directory) or use [split_encode_ccres.sh](https://github.com/BioinformaticsDataPracticum2025/open-chromatin-analysis/blob/main/split_encode_ccres.sh) if you'd like to analyze a different species. These filepaths assume that your current working directory is this repository.  
Species 1 promoters BED file:
```text
input/promoters_human.txt
```
Species 1 enhancers BED file:
```text
input/enhancers_human.txt
```
Species 2 promoters BED file:
```text
input/promoters_mouse.txt
```
Species 2 enhancers BED file:
```text
input/enhancers_mouse.txt
```

Step 6 inputs:  
Step 6 uses MEME-suite, which requires FASTA files as input. Since every step prior to this has used BED files, these BED files must be converted to FASTA using a reference genome. Although MEME-suite has its own converter, our installation lacks that converter, so we are using bedtools getfasta instead (wrapped in the `convert_bed_to_fasta.sh` script). The following files are not included in our repository due to their large size, but if you have access to the ikaplow directory, you can use these paths.  
**NOTE:** it's not possible to use the ikaplow copies of the human and mouse reference genomes because that directory is read-only, so you must make your own copies of these files.
```bash
# these are not inputs for main.sh. run this in advance.
# please change the destination to your own directory of choice.
cp "/ocean/projects/bio230007p/ikaplow/HumanGenomeInfo/hg38.fa" "/ocean/projects/bio230007p/kwang18/hg38.fa"
cp "/ocean/projects/bio230007p/ikaplow/MouseGenomeInfo/mm10.fa" "/ocean/projects/bio230007p/kwang18/mm10.fa"
```
Species 1 reference genome for converting bed to fasta (change this out with your own directory)
```text
/ocean/projects/bio230007p/kwang18/hg38.fa
```
Species 2 reference genome for converting bed to fasta (change this out with your own directory)
```text
/ocean/projects/bio230007p/kwang18/mm10.fa
```
Species 1 .meme motif database
```text
/ocean/projects/bio200034p/ikaplow/MotifData/motif_databases/HUMAN/HOCOMOCOv11_full_HUMAN_mono_meme_format.meme
```
Species 2 .meme motif database
```text
/ocean/projects/bio200034p/ikaplow/MotifData/motif_databases/MOUSE/HOCOMOCOv11_full_MOUSE_mono_meme_format.meme
```

#### Outputs  
Please refer to the test_output directory for an example of directory structure. If you would like to quickly test the pipeline using the example input files, we recommend that you place the hal subdirectory in your own output directory and also comment out the four sbatch commands that run submit_hal in step 2, as HALPER takes a long time to run. Also note that test_output in the example run is created in your $HOME directory, not within this repository directory.
Here is a list of which output subdirectories correspond to which steps:
* Step 1 (manual QC inspection of input ATAC-seq data): not part of our pipeline. Refer to the [ENCODE ATAC-seq pipeline](https://github.com/ENCODE-DCC/atac-seq-pipeline/tree/master).
* Step 2 (hal analysis): hal. Subdirectories of this are divided by species and tissue. Note: the halLiftover files were too large to upload and are not used downstream in the pipeline, so they have been deleted. Only the HALPER output files from step 2 are used downstream.
* Step 2a (cross-species intersection): cross_species
* Step 3 (cross-tissue intersection): cross_tissue
* Step 4 (GREAT gene ontology analysis): not applicable; however, you could use the intermediate files from several steps in the pipeline (particularly steps 2a, 3, and 5) as input.
* Step 5 (sorting peaks into enhancers and promoters): enhancers_and_promoters. While there are a lot of output bed files from this step, the outputs that directly answer the questions posed by 5a and 5b are the Jaccard figures in the top level of the directory. Generally the output files from step 5 are sorted into subdirectories that correspond to which step 6 task they serve as input for. However, there is no step 6a subdirectory because the inputs to step 6a are simply the four original input ATAC-seq files, and the steps 6d and 6f subdirectories contain promoter files that are not actually used in step 6.
* Step 6 (motif analysis): motifs. Please note that the version uploaded to GitHub only contains a subset of files from the output, as the entire output is too massive to put on GitHub. The files that have been included are meme-chip.html and summary.tsv, which show the motifs that are enriched in the input datasets. (Directory names indicate what the input datasets were.) Outputs that are labeled with MEME describe motifs that were discovered (with E-value as a measure of significance), while STREME outputs are motifs that are either enriched in the sequence or relatively enriched compared to control sequences.  
On the main level of the output directory, you can also find figures that visualize the Jaccard index for the overlaps performed. The [Jaccard index](https://bedtools.readthedocs.io/en/latest/content/tools/jaccard.html), which measures the size of the intersection divided by the size of the union of the two datasets. It ranges from 0 to 1, with 1 indicating more overlap between the datasets. It is a symmetrical measure that serves as an alternative to percentage overlap between two datasets, as percentage overlap is not robust to any differences in dataset size, especially if one dataset is much larger than the other.

### Individual scripts, if you'd like to run only parts of the pipeline:
**Usage of the following individual scripts (with inputs, outputs, and example runs) can be found [here](setup/SCRIPTS.md).**
- Step 2: `submit_hal.sh`, which is used to run halLiftover and HALPER. **IMPORTANT: refer to the "important note" heading in the markdown linked above. You will need to change a few lines of code in order to get this to run on your own device; according to [hal setup documentation](https://github.com/pfenninglab/halLiftover-postprocessing/blob/master/hal_install_instructions.md), it must be hardcoded without use of "~".** 
- Steps 2a, 3, and parts of 5: `bedtools.sh`, which is used to run cross-species (same tissue) and intraspecies (cross-tissue) comparison of open chromatin regions
- Step 5: `split_encode_ccres.sh` if you would like to use your own ENCODE cCREs file
- Step 6: `convert_bed_to_fasta.sh` and `motif_analysis.sh`


## Citations
* CACTUS: Paten, Benedict et al. “Cactus: Algorithms for Genome Multiple Sequence Alignment.” Genome Research 21.9 (2011): 1512–1528. Genome Research. Web.
* halLiftover and HALPER: Zhang, Xiaoyu et al. “HALPER facilitates the identification of regulatory element orthologs across species.” Bioinformatics (Oxford, England) vol. 36,15 (2020): 4339-4340. doi:10.1093/bioinformatics/btaa493
* BEDTools: Quinlan, Aaron R, and Ira M Hall. “BEDTools: a flexible suite of utilities for comparing genomic features.” Bioinformatics (Oxford, England) vol. 26,6 (2010): 841-2. doi:10.1093/bioinformatics/btq033
* GREAT: McLean, Cory Y et al. “GREAT improves functional interpretation of cis-regulatory regions.” Nature biotechnology vol. 28,5 (2010): 495-501. doi:10.1038/nbt.1630
* MEMEsuite: Bailey, Timothy L et al. “The MEME Suite.” Nucleic acids research vol. 43,W1 (2015): W39-49. doi:10.1093/nar/gkv416

## Contributors
* Shih-Ying Lin (shihying@andrew.cmu.edu)
* Peng Qiu (pengq@andrew.cmu.edu)
* Aayushi Soni (ajsoni@andrew.cmu.edu)
* Katherine Wang (kcw2@andrew.cmu.edu)

  Special thanks to:
  * Professor: Dr. Irene Kaplow (ikaplow@andrew.cmu.edu)
  * TA: Wanxing Zhang (wanxingz@andrew.cmu.edu)

## How to cite this repository
A pipeline to compare regulatory regions across tissues and species - Github repository. 2025. https://github.com/BioinformaticsDataPracticum2025/open-chromatin-analysis/
