# Environment Setup
This doc provides some basic setup instructions on an HPC system such as Bridges2.

---

## Download & Install 

### Conda 
Anaconda3 is usually available as a pre-installed module on Bridges2. If Anaconda3 does not come installed on your cluster, please [install](https://www.anaconda.com/download) it.   

**✅ Step 1: Load Anaconda Module**  
```bash
module load anaconda3
```

**✅ Step 2: Create and Activate Environment**  
```bash
conda create -n hal python=3.7
conda activate hal
```
HALPER expects the conda env name to be hal. If using another name, modify line 27 of `halper_map_peak_orthologs.sh` and change to the corresponding name. 
Detailed instructions on how to install hal and HALPER [here](https://github.com/pfenninglab/halLiftover-postprocessing/blob/master/hal_install_instructions.md).

### Git
**🧩 Step 1: Activate Env and Install Git**

```bash
conda activate hal
conda install git
```

**🧩 Step 2: Clone the Main Repository**
```bash
https://github.com/BioinformaticsDataPracticum2025/open-chromatin-analysis.git
```

You may also need to install the [ENCODE ATAC-seq data processing pipeline](https://github.com/ENCODE-DCC/atac-seq-pipeline/tree/master?tab=readme-ov-file#installation), [bedtools](https://anaconda.org/bioconda/bedtools), and [MEME-suite](https://meme-suite.org/meme/doc/install.html). Refer to the hyperlinks for their respective installation instructions.
