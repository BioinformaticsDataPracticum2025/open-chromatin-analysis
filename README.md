# Open Chromatin Analysis Pipline

## Table of Contents

- [Introduction](#introduction)

- [Requirements & Installation](#required-packages--tools)

- [Scripts](#scripts)

- [Usage](#usage)


---

## Introduction
This project explores the conservation and functional significance of open chromatin regions across human and mouse tissues, such as the ovary and pancreas. Open chromatin regions play a crucial role in regulating gene expression by providing access to transcriptional machinery. These open chromatin regions may be promoters or enhancers.  
This pipeline could generally be used to conduct differential regulatory analysis between two different conditions in  bulk ATAC-seq data, e.g. between species and tissues. 

Our goals are to:  
1. Evaluate the quality of chromatin accessibility datasets (manual inspection of ATAC-seq QC reports).
2. Identify open chromatin regions that map across species and tissues (halLiftover, HALPER).
3. Compare the percentages of open chromatin regions that are conserved between species and between tissues (bedtools intersection between ATAC-seq peaks for same-species comparison, and between halLiftover and HALPER outputs for cross-species comparison).
4. Predict functions of regulatory regions (GREAT gene ontology analysis; manual web upload).
5. Analyze conserved regulatory elements such as enhancers and promoters (bedtools intersection with ENCODE CCREs).
6. Investigate associated biological processes and transcription factor binding sites (MEME-ChIP, or just MEME and STREME).

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
- MEME-ChIP from [MEMEsuite](https://meme-suite.org/meme/doc/install.html) v5.4.1, or you can use the web version of [MEME-ChIP](https://meme-suite.org/meme/tools/meme-chip).

### IMPORTANT NOTE REGARDING HAL
**IMPORTANT: refer to the "important note" heading in the markdown linked [here](setup/SCRIPTS.md). You will need to change a few lines of code in order to get this to run on your own device; according to [hal setup documentation](https://github.com/pfenninglab/halLiftover-postprocessing/blob/master/hal_install_instructions.md), it must be hardcoded without use of "~".** 

## Scripts
### Integrated script: main.sh
main.sh prompts the user for inputs. Make sure to follow its suggestions, such as providing unique outdirs so that your outputs don't get overwritten.  
### Here is a set of example inputs to paste line by line into the console, when prompted to do so by main.sh.
Output directory (you can download a copy of this directory from our repository):
```text
test_output
```
Species 1:
```text
Human
```
Species 2:
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

**The following files are not included in our repository due to their large size, but if you have access to the ikaplow directory, you can use these paths.**  
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

**For the following enhancers and promoters BED files, you can either use our pre-split files for human and mouse (included in the input directory) or use [split_encode_ccres.sh](https://github.com/BioinformaticsDataPracticum2025/open-chromatin-analysis/blob/main/split_encode_ccres.sh) if you'd like to analyze a different species**  
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

### Individual scripts, if you'd like to run only parts of the pipeline:
**Usage of the following individual scripts (with inputs, outputs, and example runs) can be found [here](setup/SCRIPTS.md).**
- Step 2: `submit_hal.sh`, which is used to run halLiftover and HALPER. **IMPORTANT: refer to the "important note" heading in the markdown linked above. You will need to change a few lines of code in order to get this to run on your own device; according to [hal setup documentation](https://github.com/pfenninglab/halLiftover-postprocessing/blob/master/hal_install_instructions.md), it must be hardcoded without use of "~".** 
- Steps 2a and 3: `bedtools.sh`, which is used to run cross-species (same tissue) and intraspecies (cross-tissue) comparison of open chromatin regions
- TODO: add step 5 script
- Step 6: convert_bed_to_fasta.sh and motif_analysis.sh

## Usage

The usage of the main.sh will go here, including the input and output files. 

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
