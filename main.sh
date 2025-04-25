#!/bin/bash
# First prompt user for CLIs, then after all CLIs have been taken, pass them to the corresponding functions that run tasks in the pipeline

# Functions for processing:

# Function to find the first matching file and return full path
find_halper_file() {
    local outdir="$1"

    # Ensure proper concatenation: remove trailing slash if present
    outdir="${outdir%/}"

    # Find the first matching file
    local file
    file=$(find "$outdir" -type f -name '*HALPER*' | head -n 1)

    # Check if a file was found
    if [[ -z "$file" ]]; then
        echo "No matching file found."
        return 1
    fi

    # Construct full path with exactly one "/"
    echo "$outdir/$file"
}

# Example usage of find_halper_file():
#outdir="/path/to/your/directory"
#out=$(find_halper_file "$outdir")


# Note: steps 1 and 4 are not involved in the pipeline because they are separate, manual steps.


# Get inputs for step 2 (HAL)
echo "Taking inputs for HALPER."
echo "Note: enter unique outdirs for each analysis, otherwise they will overwrite each other and the pipeline will not work."

read -p "Enter the first species you are comparing (exactly as written in the alignment file): " species1
read -p "Enter the second species you are comparing (exactly as written in the alignment file): " species2
read -p "Enter the first tissue you are comparing: " tissue1
read -p "Enter the second tissue you are comparing: " tissue2

read -p "Enter the filename for the $species1 $tissue1 ATAC-seq peaks data: " s1t1
read -p "Enter the output directory for this HALPER analysis (make sure the outdir exists already): " s1t1_outdir

read -p "Enter the filename for the $species1 $tissue2 ATAC-seq peaks data: " s1t2
read -p "Enter the output directory for this HALPER analysis (make sure the outdir exists already): " s1t2_outdir

read -p "Enter the filename for the $species2 $tissue1 ATAC-seq peaks data: " s2t1
read -p "Enter the output directory for this HALPER analysis (make sure the outdir exists already): " s2t1_outdir

read -p "Enter the filename for the $species2 $tissue2 ATAC-seq peaks data: " s2t2
read -p "Enter the output directory for this HALPER analysis (make sure the outdir exists already): " s2t2_outdir


# Get inputs for steps 2a and 3 (bedtools intersection to find shared OCRs between species and between tissues):

# First of all, get outputs for step 2 (HAL), because these will be used for step 2a (between species)
# The logic: return the name of the first file
s1t1_out=$(find_halper_file "$s1t1_outdir")
s1t2_out=$(find_halper_file "$s1t2_outdir")
s2t1_out=$(find_halper_file "$s2t1_outdir")
s2t2_out=$(find_halper_file "$s1t2_outdir")

# Step 3 (between tissues) will compare the ATAC-seq files that were provided as input for step 2, so we already have all the info we need for step 3.


# TODO: get step 5 inputs, if there are any additional inputs (like output directories or output filenames).
# I think we should include the ENCODE cCREs (split by enhancers and promoters) in the repo so that the user can just download them and use them

# TODO: get step 6 inputs.



# Run step 2 (HAL)
sbatch submit_hal.sh -b $s1t1 -o $s1t1_outdir -s $species1 -t $species2
sbatch submit_hal.sh -b $s1t2 -o $s1t2_outdir -s $species1 -t $species2
sbatch submit_hal.sh -b $s2t1 -o $s2t1_outdir -s $species2 -t $species1
sbatch submit_hal.sh -b $s2t2 -o $s2t2_outdir -s $species2 -t $species1
echo "Submitted HALPER jobs; use squeue -u <your usernane> to check their progress."
echo "Outputs for HALPER jobs can be found in the outdirs specified. The outputs that will be used in subsequent steps are the ones that end with 'HALPER.narrowPeak.gz'.

# TODO: run step 2a (cross-species same-tissue intersection)

# TODO: run step 3 (intra-species cross-tissue intersection)

# TODO: run step 5

# TODO: run step 6