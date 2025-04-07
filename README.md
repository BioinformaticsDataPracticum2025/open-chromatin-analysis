# open-chromatin-analysis

This project explores the conservation and functional significance of open chromatin regions across human and mouse tissues, such as the ovary and pancreas. Open chromatin regions play a crucial role in regulating gene expression by providing access to transcriptional machinery. These open chromatin regions may be promoters or enhancers. 

Our goals are to:  
1. Evaluate the quality of chromatin accessibility datasets (manual inspection of ATAC-seq QC reports).
2. Identify open chromatin regions that map across species and tissues (halLiftover, HALPER).
3. Compare the percentages of open chromatin regions that are conserved between species and between tissues (bedtools intersection between ATAC-seq peaks for same-species comparison, and between halLiftover and HALPER outputs for cross-species comparison).
4. Predict functions of regulatory regions (GREAT gene ontology analysis; manual web upload).
5. Analyze conserved regulatory elements such as enhancers and promoters (bedtools intersection with ENCODE CCREs).
6. Investigate associated biological processes and transcription factor binding sites (MEMEsuite; specific software TBD).

---

## Required Packages & Tools
To run the analyses and workflows in this project, the following packages and tools are required. Initial setup is available [here](setup/README.md). 

- **[halLiftover and HALPER](https://github.com/pfenninglab/halLiftover-postprocessing.git)**
- GREAT
- MEMEsuite
