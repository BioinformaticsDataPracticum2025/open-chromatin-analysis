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
read -p "Enter the output directory for this HALPER $species1 to $species2 $tissue1 analysis (make sure the outdir exists already): " s1t1_outdir

read -p "Enter the filename for the $species1 $tissue2 ATAC-seq peaks data: " s1t2
read -p "Enter the output directory for this HALPER $species1 to $species2 $tissue2 analysis (make sure the outdir exists already): " s1t2_outdir

read -p "Enter the filename for the $species2 $tissue1 ATAC-seq peaks data: " s2t1
read -p "Enter the output directory for this HALPER $species2 to $species1 $tissue1 analysis (make sure the outdir exists already): " s2t1_outdir

read -p "Enter the filename for the $species2 $tissue2 ATAC-seq peaks data: " s2t2
read -p "Enter the output directory for this HALPER $species2 to $species1 $tissue2 analysis (make sure the outdir exists already): " s2t2_outdir


# Get inputs for steps 2a and 3 (bedtools intersection to find shared OCRs between species and between tissues):
# Using outputs from step 2 HAL (see below right after the HAL jobs are submitted)

# Also get output directory for step 2a
read -p "Enter the output directory for cross-species intersections (step 2a), making sure it already exists: " step2a_outdir
step2a_outdir="${step2a_outdir%/}" # remove trailing slash if present

# Step 3 (between tissues) will compare the ATAC-seq files that were provided as input for step 2. Just need to get an outdir.
read -p "Enter the output directory for cross-tissue intersections (step 3), making sure it already exists: " step3_outdir
step3_outdir="${step3_outdir%/}" # remove trailing slash if present

# TODO: get step 5 inputs, if there are any additional inputs (like output directories or output filenames).
# I think we should include the ENCODE cCREs (split by enhancers and promoters) in the repo so that the user can just download them and use them

# TODO: get step 6 inputs.



# Run step 2 (HAL)

# Submit jobs and store their job IDs
job_ids=()
job_ids+=($(sbatch submit_hal.sh -b "$s1t1" -o "$s1t1_outdir" -s "$species1" -t "$species2" | awk '{print $4}'))
job_ids+=($(sbatch submit_hal.sh -b "$s1t2" -o "$s1t2_outdir" -s "$species1" -t "$species2" | awk '{print $4}'))
job_ids+=($(sbatch submit_hal.sh -b "$s2t1" -o "$s2t1_outdir" -s "$species2" -t "$species1" | awk '{print $4}'))
job_ids+=($(sbatch submit_hal.sh -b "$s2t2" -o "$s2t2_outdir" -s "$species2" -t "$species1" | awk '{print $4}'))

echo "Submitted HALPER jobs with IDs: ${job_ids[*]}"
echo "Use squeue -u <your username> to check their progress."
echo "Outputs for HALPER jobs can be found in the outdirs specified. The outputs that will be used in subsequent steps are the ones that end with 'HALPER.narrowPeak.gz'."

# Wait for all jobs to finish
while true; do
    active_jobs=0
    for job_id in "${job_ids[@]}"; do
        if squeue -j "$job_id" >/dev/null 2>&1; then
            active_jobs=$((active_jobs+1))
        fi
    done

    if [[ "$active_jobs" -eq 0 ]]; then
        break
    fi

    echo "Waiting for jobs: ${job_ids[*]} to finish..."
    sleep 1800  # Check progress every 30 minutes
done

echo "All HALPER jobs have completed. Proceeding with next steps."

# Get outputs for step 2 (HAL), because these will be used for step 2a (between species)
# The logic: return the name of the first file
s1t1_hal=$(find_halper_file "$s1t1_outdir")
s1t2_hal=$(find_halper_file "$s1t2_outdir")
s2t1_hal=$(find_halper_file "$s2t1_outdir")
s2t2_hal=$(find_halper_file "$s1t2_outdir")


# Run step 2a (cross-species same-tissue intersection)
bash bedtools.sh $s1t1_hal $s2t1 "${step2a_outdir}/${species1}_to_${species2}_open.bed" y "Shared OCRs between ${species1} and ${species2} ${tissue1}"
bash bedtools.sh $s1t1_hal $s2t1 "${step2a_outdir}/${species1}_to_${species2}_closed.bed" n "OCRs unique to ${species1} ${tissue1}"
# TODO: the rest of step 2a (I think there are 8 in total)

# TODO: run step 3 (intra-species cross-tissue intersection)

# TODO: run step 5

# TODO: run step 6 (use sbatch because it'll take a long time to run)

