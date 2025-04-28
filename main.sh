#!/bin/bash
# First prompt user for CLIs, then after all CLIs have been taken, pass them to the corresponding functions that run tasks in the pipeline
# Note: steps 1 and 4 are not involved in the pipeline because they are separate, manual steps.

# Functions for processing:

# Function to find the first matching file and return full path
find_halper_file() {
    local outdir="$1"
    # echo "Looking for halper file in ${outdir}" # nvm, can't echo anything that isn't intended to be in the output
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
    # echo "$outdir/$file"
    echo "$file" # let's see if this fixes the error
}

# Example usage of find_halper_file():
#outdir="/path/to/your/directory"
#out=$(find_halper_file "$outdir")


# helper function to run bedtools.sh 
run_bedtools() {
    local fileA=$1
    local fileB=$2
    local out=$3
    local mode=$4
    local name=$5
    local all_out

    # echo fileA $fileA
    # echo fileB $fileB
    # echo out $out
    # echo mode $mode
    # echo name $name
    all_out=$(bash bedtools.sh "$fileA" "$fileB" "$out" "$mode")
    # echo "All out: ${all_out}"
    printf '%s\n' "$all_out" | sed \$d

    local j
    j=$(printf '%s\n' "$all_out" | tail -n1)

    echo "Jaccard overlap for the intersection that created $out: $j%"

    jaccard_arr+=("$j")
    names_arr+=("$name")
}

# First, establish the output directory where everything will go.
echo "Before entering an output directory, note that if prior analyses were conducted in this outdir, they will be overwritten."
read -p "Enter the output directory for this pipeline. This will be created in ${HOME}: " pipe_out
pipe_out="${HOME}/${pipe_out%/}" # place in the home directory, and strip the "/" if one was included
mkdir -p $pipe_out # make this directory in case it doesn't already exist

echo "Step 1 of the pipeline was to perform QC on the input data that you are about to provide for step 2."

# Get inputs for step 2 (HAL)
echo "Taking inputs for HALPER (step 2)."
# echo "Note: enter unique outdirs for each analysis, otherwise they will overwrite each other and the pipeline will not work."
# echo "Also, outdirs will be placed in ${HOME}."

# hal_out="test_output/hal" # maybe allow the user to set this

read -p "Enter the first species you are comparing (exactly as written in the alignment file): " species1
read -p "Enter the second species you are comparing (exactly as written in the alignment file): " species2
read -p "Enter the first tissue you are comparing: " tissue1
read -p "Enter the second tissue you are comparing: " tissue2

read -p "Enter the filename for the $species1 $tissue1 ATAC-seq peaks data: " s1t1
# read -p "Enter the output directory for this HALPER $species1 to $species2 $tissue1 analysis: " s1t1_outdir
# s1t1_outdir="${HOME}/${s1t1_outdir%/}"
# s1t1_outdir="${HOME}/${hal_out}/${species1}/${tissue1}"
s1t1_outdir="${pipe_out}/hal/${species1}/${tissue1}"
mkdir -p $s1t1_outdir

read -p "Enter the filename for the $species1 $tissue2 ATAC-seq peaks data: " s1t2
# read -p "Enter the output directory for this HALPER $species1 to $species2 $tissue2 analysis: " s1t2_outdir
# s1t2_outdir="${HOME}/${s1t2_outdir%/}"
# s1t2_outdir="${HOME}/${hal_out}/${species1}/${tissue2}"
s1t2_outdir="${pipe_out}/hal/${species1}/${tissue2}"
mkdir -p $s1t2_outdir

read -p "Enter the filename for the $species2 $tissue1 ATAC-seq peaks data: " s2t1
# read -p "Enter the output directory for this HALPER $species2 to $species1 $tissue1 analysis: " s2t1_outdir
# s2t1_outdir="${HOME}/${s2t1_outdir%/}"
# s2t1_outdir="${HOME}/${hal_out}/${species2}/${tissue1}"
s2t1_outdir="${pipe_out}/hal/${species2}/${tissue1}"
mkdir -p $s2t1_outdir

read -p "Enter the filename for the $species2 $tissue2 ATAC-seq peaks data: " s2t2
# read -p "Enter the output directory for this HALPER $species2 to $species1 $tissue2 analysis: " s2t2_outdir
# s2t2_outdir="${HOME}/${s2t2_outdir%/}"
# s2t2_outdir="${HOME}/${hal_out}/${species2}/${tissue2}"
s2t2_outdir="${pipe_out}/hal/${species2}/${tissue2}"
mkdir -p $s2t2_outdir

echo "Look for step 2 outputs in the following directories:"
echo $s1t1_outdir
echo $s1t2_outdir
echo $s2t1_outdir
echo $s2t2_outdir

# Get inputs for steps 2a and 3 (bedtools intersection to find shared OCRs between species and between tissues):
# Using outputs from step 2 HAL (see below right after the HAL jobs are submitted)

# consider automatically making the step 2a and step 3 outdirs, printing the directories to the console
# Also get output directory for step 2a
# read -p "Enter the output directory for cross-species intersections (step 2a), making sure it already exists: " step2a_outdir
# step2a_outdir="${HOME}/${step2a_outdir%/}" # remove trailing slash if present
step2a_outdir="${pipe_out}/cross_species"
mkdir -p $step2a_outdir

# Step 3 (between tissues) will compare the ATAC-seq files that were provided as input for step 2. Just need to get an outdir.
# read -p "Enter the output directory for cross-tissue intersections (step 3), making sure it already exists: " step3_outdir
# step3_outdir="${HOME}/${step3_outdir%/}" # remove trailing slash if present
step3_outdir="${pipe_out}/cross_tissue"
mkdir -p $step3_outdir


# TODO: get step 5 inputs, if there are any additional inputs (like output directories or output filenames).
#We have included the ENCODE cCREs (split by enhancers and promoters) in the repo so that the user can just download them and use them

# TODO: get step 6 inputs.



# Run step 2 (HAL)

# Submit jobs and store their job IDs
# Commenting this out for now, in order to test the pipeline
job_ids=()
# job_ids+=($(sbatch submit_hal.sh -b "$s1t1" -o "$s1t1_outdir" -s "$species1" -t "$species2" | awk '{print $4}'))
# job_ids+=($(sbatch submit_hal.sh -b "$s1t2" -o "$s1t2_outdir" -s "$species1" -t "$species2" | awk '{print $4}'))
# job_ids+=($(sbatch submit_hal.sh -b "$s2t1" -o "$s2t1_outdir" -s "$species2" -t "$species1" | awk '{print $4}'))
# job_ids+=($(sbatch submit_hal.sh -b "$s2t2" -o "$s2t2_outdir" -s "$species2" -t "$species1" | awk '{print $4}'))

echo "Submitted HALPER jobs with IDs: ${job_ids[*]}"
echo "Use squeue -u ${USER} to check their progress."
echo "Outputs for HALPER jobs can be found in the hal_out directory (in your home directory). The outputs that will be used in subsequent steps are the ones that end with 'HALPER.narrowPeak.gz'."

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
echo "Running step 2a (cross-species, same-tissue intersection)"
echo "Look for outputs of step 2a here: ${step2a_outdir}"
jaccard_arr=()
names_arr=()

# run_bedtools "$s1t1_hal" "$s2t1" "${step2a_outdir}/${species1}_to_${species2}_open.bed" "y" "Shared OCRs between ${species1} and ${species2} ${tissue1}"
# run_bedtools "$s1t1_hal" "$s2t1" "${step2a_outdir}/${species1}_to_${species2}_closed.bed" "n" "OCRs unique to ${species1} ${tissue1}"

# In order to avoid redundancy when generating the plot, only use the run_bedtools function on one intersection per pair of files
# e.g. for the same intersection done with y and n modes, use run_bedtools on the first in order to add the info to jaccard_arr and names_arr,
# but the second is run with vanilla "bash bedtools.sh" so that it doesn't show up a second time
# because Jaccard is supposed to be symmetrical
# run_bedtools "$s1t1_hal" "$s2t1" "${species1}_to_${species2}_open.bed" "y" "Shared OCRs between ${species1} and ${species2} ${tissue1}"
# bash bedtools.sh "$s1t1_hal" "$s2t1" "${species1}_to_${species2}_closed.bed" "n" "OCRs unique to ${species1} ${tissue1}" # this might be in the wrong directory
# run_bedtools "$s1t1_hal" "$s2t1" "${species1}_to_${species2}_closed.bed" "n" "OCRs unique to ${species1} ${tissue1}"

# species 1 against species 2, tissue 1
run_bedtools "$s1t1_hal" "$s2t1" "${step2a_outdir}/${species1}_to_${species2}_${tissue1}_open.bed" "y" "Shared OCRs between ${species1} and ${species2} ${tissue1}"
run_bedtools "$s1t1_hal" "$s2t1" "${step2a_outdir}/${species1}_to_${species2}_${tissue1}_closed.bed" "n" "OCRs unique to ${species1} ${tissue1}"

# species 2 against species 1, tissue 1
run_bedtools "$s2t1_hal" "$s1t1" "${step2a_outdir}/${species2}_to_${species1}_${tissue1}_open.bed" "y" "Shared OCRs between ${species2} and ${species1} ${tissue1}"
run_bedtools "$s2t1_hal" "$s1t1" "${step2a_outdir}/${species2}_to_${species1}_${tissue1}_closed.bed" "n" "OCRs unique to ${species2} ${tissue1}"

# species 1 against species 2, tissue 2
run_bedtools "$s1t2_hal" "$s2t2" "${step2a_outdir}/${species1}_to_${species2}_${tissue2}_open.bed" "y" "Shared OCRs between ${species1} and ${species2} ${tissue2}"
run_bedtools "$s1t2_hal" "$s2t2" "${step2a_outdir}/${species1}_to_${species2}_${tissue2}_closed.bed" "n" "OCRs unique to ${species1} ${tissue2}"

# species 2 against species 1, tissue 2
run_bedtools "$s2t2_hal" "$s1t2" "${step2a_outdir}/${species2}_to_${species1}_${tissue2}_open.bed" "y" "Shared OCRs between ${species2} and ${species1} ${tissue2}"
run_bedtools "$s2t2_hal" "$s1t2" "${step2a_outdir}/${species2}_to_${species1}_${tissue2}_closed.bed" "n" "OCRs unique to ${species2} ${tissue2}"


# TODO: the rest of step 2a (I think there are 8 in total)

# after running all the intersection, visualize this! 
echo "Check ${pipe_out} for a visualization of the cross-species Jaccard index!"
jaccard_string=$(IFS=,; echo "${jaccard_arr[*]}")
names_string=$(IFS=,; echo "${names_arr[*]}")
python python_scripts/plot_radial_new.py --names "$names_string" --jaccard "$jaccard_string" --out "${pipe_out}/step2a_cross_species_jaccard.png"
echo "Done drawing for step 2a!"

# TODO: run step 3 (intra-species cross-tissue intersection)
echo "Running step 3 (intra-species, cross-tissue intersection)"
echo "Look for outputs of step 3 here: ${step3_outdir}"

jaccard_arr=()
names_arr=()



# after running all the intersection, visualize this! 
echo "Check ${pipe_out} for visualizations of Jaccard index!" # TODO: there will be multiple of these, so print what they're for, as well as their names
jaccard_string=$(IFS=,; echo "${jaccard_arr[*]}")
names_string=$(IFS=,; echo "${names_arr[*]}")
python python_scripts/plot_radial_new.py --names "$names_string" --jaccard "$jaccard_string" --out "${pipe_out}/example_file_name.png" # change the name, including filepath, later 

# TODO: run step 5

# TODO: run step 6 (use sbatch because it'll take a long time to run)

echo "Once these sbatch jobs have finished, the pipeline is complete!"