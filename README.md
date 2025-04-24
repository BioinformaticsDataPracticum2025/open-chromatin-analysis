# open-chromatin-analysis

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

- [Anaconda3](https://www.anaconda.com/docs/getting-started/anaconda/install) for conda installation and Python
- [bedtools](https://anaconda.org/bioconda/bedtools) (can be conda installed)
- **[halLiftover and HALPER](https://github.com/pfenninglab/halLiftover-postprocessing.git)**
- [GREAT](http://great.stanford.edu/public/html/) (please make sure that your input BED files have been cut to columns 1-3)
```bash
cut -f1-3 input_bed_file  > output_file_name 
# This keeps only the first 3 columns of the file.
```
- MEME-ChIP [MEMEsuite](https://meme-suite.org/meme/doc/install.html) v5.4.1, or you can use the web version of [MEME-ChIP](https://meme-suite.org/meme/tools/meme-chip).

## Scripts
- (Integrated scripts here; below are individual scripts)

**Usage of the following scripts (with inputs and outputs) can be found [here](setup/SCRIPTS.md).**
- `submit_hal.sh`, which is used to run halLiftover and HALPER. **IMPORTANT: refer to the "important note" heading in the markdown linked above. You will need to change a few lines of code in order to get this to run on your own device; according to [hal setup documentation](https://github.com/pfenninglab/halLiftover-postprocessing/blob/master/hal_install_instructions.md), it must be hardcoded without use of "~".** 
- `bedtools.sh`, which is used to run cross-species (same tissue) and intraspecies (cross-tissue) comparison of open chromatin regions

(note to self: although submit_hal.sh is currently configured to accept zipped input narrowPeak files and automatically unzip to ~/input/peaks.narrowPeak, this is an issue if running HALPER multiple times because then the input ATAC-seq data will overwrite each other, and we will probably want to access these unzipped narrowPeak files later. So we should modify submit_hal.sh so that if it detects that the user gave it zipped .narrowPeak files, it prompts the user to provide new filenames to use when unzipping the file, e.g. with gunzip -c $zipped_input > $unzipped_input. Also note that the HALPER output files will differ in names depending on the input file's name and the source and target species, so the easiest way to identify them would be to search for "HALPER" in the filename.)

## Example run
(TODO: list the input files, output files, and bash/sbatch commands)

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
