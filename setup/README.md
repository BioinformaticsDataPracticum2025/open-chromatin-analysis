# Environment Setup
This doc provides some basic setup instructions on an HPC system such as Bridges2.

---

## Download & Install 

### Conda 
Anaconda is usually available as a pre-installed module on Bridges2.   

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

### Git
```bash
conda activate hal
conda install git
git clone https://github.com/BioinformaticsDataPracticum2025/open-chromatin-analysis.git
```

