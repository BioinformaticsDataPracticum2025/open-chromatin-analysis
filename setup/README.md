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
**🧩 Step 3: Clone the HALPER Repository**
```bash
cd open-chromatin-analysis
git clone https://github.com/pfenninglab/halLiftover-postprocessing.git
```

