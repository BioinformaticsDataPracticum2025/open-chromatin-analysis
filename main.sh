#!/bin/bash
# First prompt user for CLIs, then after all CLIs have been taken, pass them to the corresponding functions that run tasks in the pipeline
# Note: steps 1 and 4 are not involved in the pipeline because they are separate, manual steps.

module load anaconda3
source activate hal

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

echo "Do not include quotation marks around filepaths."
read -p "Enter the filename for the Cactus alignment you are using: " align

read -p "Enter the first species you are comparing, exactly as written in the Cactus alignment file: " species1
read -p "Enter the second species you are comparing, exactly as written in the Cactus alignment file: " species2
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


# Get step 5 inputs, which are paths to enhancers and promoters for species1 and for species2.
# We have included the ENCODE cCREs (split by enhancers and promoters) in the repo for ease of use, in the input directory.
# echo this: The user would be responsible for using that script to split the ENCODE cCREs file before running the pipeline
# echo a message here to indicate getting step 5 inputs
echo "Taking inputs for enhancer and promoter analysis (step 5)"
echo "Mouse and human enhancers and promoters can be found in the input directory in this repository."
echo "If you would like to analyze a species that isn't human or mouse, use split_encode_ccres.sh to get the enhancers and promoters."
read -p "Enter the ${species1} promoters file: " s1p
read -p "Enter the ${species1} enhancers file: " s1e
read -p "Enter the ${species2} promoters file: " s2p
read -p "Enter the ${species2} enhancers file: " s2e

# Also set up a directory for step 5 outputs
step5_outdir="${pipe_out}/enhancers_and_promoters"
mkdir -p $step5_outdir


# Get step 6 inputs.
echo "Taking inputs for motif analysis (step 6)"

# Get reference genomes for species 1 and species 2
read -p "Enter a reference genome for ${species1}, with a file ending in either .fasta or .fa: " s1_genome
read -p "Enter a reference genome for ${species2}, with a file ending in either .fasta or .fa: " s2_genome

# Get filenames of the .meme databases, one for each species.
read -p "Enter a .meme motif database file for ${species1}: " s1_meme
read -p "Enter a .meme motif database file for ${species2}: " s2_meme

# Also set up a directory for step 6 outputs, which will be passed to MEME-ChIP
step6_outdir="${pipe_out}/motifs"
mkdir -p $step6_outdir


# Run step 2 (HAL)
echo "Look for step 2 outputs in the following directories:"
echo $s1t1_outdir
echo $s1t2_outdir
echo $s2t1_outdir
echo $s2t2_outdir
echo "Running step 2 (HALPER)..."

# Submit jobs and store their job IDs
# To quickly test the pipeline, comment out the four sbatch commands below. The hal output files will be included in the test_output directory.
job_ids=()
# job_ids+=($(sbatch submit_hal.sh -b "$s1t1" -o "$s1t1_outdir" -s "$species1" -t "$species2" -c "$align" | awk '{print $4}'))
# job_ids+=($(sbatch submit_hal.sh -b "$s1t2" -o "$s1t2_outdir" -s "$species1" -t "$species2" -c "$align" | awk '{print $4}'))
# job_ids+=($(sbatch submit_hal.sh -b "$s2t1" -o "$s2t1_outdir" -s "$species2" -t "$species1" -c "$align" | awk '{print $4}'))
# job_ids+=($(sbatch submit_hal.sh -b "$s2t2" -o "$s2t2_outdir" -s "$species2" -t "$species1" -c "$align" | awk '{print $4}'))

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

    echo "Waiting for jobs: ${job_ids[*]} to finish... Will check every 5 minutes"
    sleep 300  # Check progress every 5 minutes
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

# after running all the intersection, visualize this! 
echo "Check ${pipe_out} for a visualization of the step 2a cross-species Jaccard index!"
jaccard_string=$(IFS=,; echo "${jaccard_arr[*]}")
names_string=$(IFS=,; echo "${names_arr[*]}")
python python_scripts/plot_radial_new.py --names "$names_string" --jaccard "$jaccard_string" --out "${pipe_out}/step2a_cross_species_jaccard.png"
echo "Done drawing for step 2a!"

# Run step 3 (intra-species cross-tissue intersection)
echo "Running step 3 (intra-species, cross-tissue intersection)"
echo "Look for outputs of step 3 here: ${step3_outdir}"
# reset jaccard_arr and names_arr because we'll make a new plot for this set of intersections
jaccard_arr=()
names_arr=()

# species 1, tissue 1 against tissue 2
run_bedtools "$s1t1" "$s1t2" "${step3_outdir}/${species1}_${tissue1}_to_${tissue2}_open.bed" "y" "Shared OCRs between ${species1} ${tissue1} and ${tissue2}"
run_bedtools "$s1t1" "$s1t2" "${step3_outdir}/${species1}_${tissue1}_to_${tissue2}_closed.bed" "n" "OCRs unique to ${species1} ${tissue1}"

# species 1, tissue 2 against tissue 1
run_bedtools "$s1t2" "$s1t1" "${step3_outdir}/${species1}_${tissue2}_to_${tissue1}_open.bed" "y" "Shared OCRs between ${species1} ${tissue2} and ${tissue1}"
run_bedtools "$s1t2" "$s1t1" "${step3_outdir}/${species1}_${tissue2}_to_${tissue1}_closed.bed" "n" "OCRs unique to ${species1} ${tissue2}"

# species 2, tissue 1 against tissue 2
run_bedtools "$s2t1" "$s2t2" "${step3_outdir}/${species2}_${tissue1}_to_${tissue2}_open.bed" "y" "Shared OCRs between ${species2} ${tissue1} and ${tissue2}"
run_bedtools "$s2t1" "$s2t2" "${step3_outdir}/${species2}_${tissue1}_to_${tissue2}_closed.bed" "n" "OCRs unique to ${species2} ${tissue1}"

# species 2, tissue 2 against tissue 1
run_bedtools "$s2t2" "$s2t1" "${step3_outdir}/${species2}_${tissue2}_to_${tissue1}_open.bed" "y" "Shared OCRs between ${species2} ${tissue2} and ${tissue1}"
run_bedtools "$s2t2" "$s2t1" "${step3_outdir}/${species2}_${tissue2}_to_${tissue1}_closed.bed" "n" "OCRs unique to ${species2} ${tissue2}"

# after running all the intersection, visualize this! 
echo "Check ${pipe_out} for visualizations of the step 3 cross-tissue Jaccard index!"
jaccard_string=$(IFS=,; echo "${jaccard_arr[*]}")
names_string=$(IFS=,; echo "${names_arr[*]}")
python python_scripts/plot_radial_new.py --names "$names_string" --jaccard "$jaccard_string" --out "${pipe_out}/step3_cross_tissue_jaccard.png"

echo "Step 4 of the pipeline is to upload the steps 2a and 3 outputs to the GREAT webtool here: http://great.stanford.edu/public/html/"

# Run step 5
# Some bedtools intersections are done to produce intermediate files, and we don't need the Jaccard for them. In that case, use bedtools intersect directly.
# For the ones that require Jaccard, use run_bedtools.
module load bedtools

echo "Running step 5 (enhancer and promoter analysis)"
echo "Look for outputs of step 5 here: ${step5_outdir}"
echo "Outputs that are used for step 6 will be placed in subdirectories named after the corresponding part of step 6, as described in 03-713-ProjectDescription-2025.pdf."

# note that step 6a's inputs are just the four input ATAC-seq files that the user provided at the beginning.

mkdir -p "${step5_outdir}/6b"
echo "Splitting input ATAC-seq peak data for ${species1} and ${species2} into enhancers... Outputs will go in ${step5_outdir}/6b"

# get enhancers for species1 data
s1t1e="${step5_outdir}/6b/${species1}_${tissue1}_enhancers.bed"
s1t2e="${step5_outdir}/6b/${species1}_${tissue2}_enhancers.bed"
bedtools intersect -a $s1t1 -b $s1e -u > $s1t1e
bedtools intersect -a $s1t2 -b $s1e -u > $s1t2e

# get enhancers for species2 data
s2t1e="${step5_outdir}/6b/${species2}_${tissue1}_enhancers.bed"
s2t2e="${step5_outdir}/6b/${species2}_${tissue2}_enhancers.bed"
bedtools intersect -a $s2t1 -b $s2e -u > $s2t1e
bedtools intersect -a $s2t2 -b $s2e -u > $s2t2e


mkdir -p "${step5_outdir}/6c"
echo "Splitting input ATAC-seq peak data for ${species1} and ${species2} into promoters... Outputs will go in ${step5_outdir}/6c"

# get promoters for species1 data
s1t1p="${step5_outdir}/6c/${species1}_${tissue1}_promoters.bed"
s1t2p="${step5_outdir}/6c/${species1}_${tissue2}_promoters.bed"
bedtools intersect -a $s1t1 -b $s1p -u > $s1t1p
bedtools intersect -a $s1t2 -b $s1p -u > $s1t2p

# get promoters for species2 data
s2t1p="${step5_outdir}/6c/${species2}_${tissue1}_promoters.bed"
s2t2p="${step5_outdir}/6c/${species2}_${tissue2}_promoters.bed"
bedtools intersect -a $s2t1 -b $s2p -u > $s2t1p
bedtools intersect -a $s2t2 -b $s2p -u > $s2t2p


# Need to do cross-species intersection for step 5b (which connects to 6f), so need to split HALPER output files into enhancers and promoters.
# For the cross-species comparison, will map species1 to the coordinates of species2. 
echo "Splitting HALPER peak data for ${species1} and ${species2} into enhancers and promoters... Outputs will go in ${step5_outdir}"

# get enhancers for both tissues mapped from species1 to the coordinates of species2
# Note that because these are in species2 coordinates, we use the species2 enhancers.
s1t1e_hal="${step5_outdir}/${species1}_mappedTo_${species2}_${tissue1}_enhancers.bed"
s1t2e_hal="${step5_outdir}/${species1}_mappedTo_${species2}_${tissue2}_enhancers.bed"
bedtools intersect -a $s1t1_hal -b $s2e -u > $s1t1e_hal
bedtools intersect -a $s1t2_hal -b $s2e -u > $s1t2e_hal

# get promoters for both tissues mapped from species1 to the coordinates of species2
# Note that because these are in species2 coordinates, we use the species2 promoters.
s1t1p_hal="${step5_outdir}/${species1}_mappedTo_${species2}_${tissue1}_promoters.bed"
s1t2p_hal="${step5_outdir}/${species1}_mappedTo_${species2}_${tissue2}_promoters.bed"
bedtools intersect -a $s1t1_hal -b $s2p -u > $s1t1p_hal
bedtools intersect -a $s1t2_hal -b $s2p -u > $s1t2p_hal


# use run_bedtools for this set of intersections (step 5a) because we want to track the Jaccard for these intersections
echo "Running step 5a, which compares the Jaccard index of enhancers shared across tissues to the Jaccard index of promoters shared across tissues."
# reset jaccard_arr and names_arr because we'll make a new plot for this set of intersections
jaccard_arr=()
names_arr=()

mkdir -p "${step5_outdir}/6d"
echo "Finding enhancers shared between ${tissue1} and ${tissue2} within each species... Outputs will go in ${step5_outdir}/6d"
# For this, we need to intersect the files that we just created in the 6b directory.
s1e_shared="${step5_outdir}/6d/${species1}_crossTissue_enhancers.bed"
s2e_shared="${step5_outdir}/6d/${species2}_crossTissue_enhancers.bed"
run_bedtools "$s1t1e" "$s1t2e" "$s1e_shared" "y" "${species1} enhancers shared across tissues"
run_bedtools "$s2t1e" "$s2t2e" "$s2e_shared" "y" "${species2} enhancers shared across tissues"

echo "Finding promoters shared between ${tissue1} and ${tissue2} within each species... Outputs will go in ${step5_outdir}/6d"
# For this, we need to intersect the files that we just created in the 6c directory.
# Note that these promoter intersection BED files aren't actually used in step 6d, or in step 6 at all.
s1p_shared="${step5_outdir}/6d/${species1}_crossTissue_promoters.bed"
s2p_shared="${step5_outdir}/6d/${species2}_crossTissue_promoters.bed"
run_bedtools "$s1t1p" "$s1t2p" "$s1p_shared" "y" "${species1} promoters shared across tissues"
run_bedtools "$s2t1p" "$s2t2p" "$s2p_shared" "y" "${species2} promoters shared across tissues"

# visualize the Jaccard for cross-tissue comparisons
echo "Check ${pipe_out} for visualizations of the step 5a (cross-tissue comparison) Jaccard indices!"
jaccard_string=$(IFS=,; echo "${jaccard_arr[*]}")
names_string=$(IFS=,; echo "${names_arr[*]}")
python python_scripts/plot_radial_new.py --names "$names_string" --jaccard "$jaccard_string" --out "${pipe_out}/step5a_cross_tissue_jaccard.png"

echo "Step 5a has been completed."


# 6e has nothing to do with either step 5a or step 5b
mkdir -p "${step5_outdir}/6e"
echo "Finding enhancers specific to ${tissue1} and specific to ${tissue2} within each species... Outputs will go in ${step5_outdir}/6e"
# This is like the first part of the 6d set of intersections, but ultimately with a -v flag instead of -u flag (as -u underlies the "y" mode)

# For species 1:
s1e_t1only="${step5_outdir}/6e/${species1}_${tissue1}Only_enhancers.bed"
bedtools intersect -a $s1t1e -b $s1t2e -v > $s1e_t1only
s1e_t2only="${step5_outdir}/6e/${species1}_${tissue2}Only_enhancers.bed"
bedtools intersect -a $s1t2e -b $s1t1e -v > $s1e_t2only

# For species 2:
s2e_t1only="${step5_outdir}/6e/${species2}_${tissue1}Only_enhancers.bed"
bedtools intersect -a $s2t1e -b $s2t2e -v > $s2e_t1only
s2e_t2only="${step5_outdir}/6e/${species2}_${tissue2}Only_enhancers.bed"
bedtools intersect -a $s2t2e -b $s2t1e -v > $s2e_t2only



# use run_bedtools for this set of intersections (step 5b) because we want to track the Jaccard for these intersections
mkdir -p "${step5_outdir}/6f"
echo "Running step 5b, which compares the Jaccard index of enhancers shared across species to the Jaccard index of promoters shared across species."
# reset jaccard_arr and names_arr because we'll make a new plot for this set of intersections
jaccard_arr=()
names_arr=()

echo "Finding enhancers shared across species for each tissue... Outputs will go in ${step5_outdir}/6f"
t1e_shared="${step5_outdir}/6f/bothSpecies_${tissue1}_enhancers.bed"
t2e_shared="${step5_outdir}/6f/bothSpecies_${tissue2}_enhancers.bed"
run_bedtools "$s1t1e_hal" "$s2t1e" "$t1e_shared" "y" "${tissue1} enhancers shared across species"
run_bedtools "$s1t2e_hal" "$s2t2e" "$t2e_shared" "y" "${tissue2} enhancers shared across species"

echo "Finding promoters shared between ${species1} and ${species2} for each tissue... Outputs will go in ${step5_outdir}/6f"
t1p_shared="${step5_outdir}/6f/bothSpecies_${tissue1}_promoters.bed"
t2p_shared="${step5_outdir}/6f/bothSpecies_${tissue2}_promoters.bed"
run_bedtools "$s1t1p_hal" "$s2t1p" "$t1p_shared" "y" "${tissue1} promoters shared across species"
run_bedtools "$s1t2p_hal" "$s2t2p" "$t2p_shared" "y" "${tissue2} promoters shared across species"

# visualize the Jaccard.
echo "Check ${pipe_out} for visualizations of the step 5b (cross-species comparison) Jaccard indices!"
jaccard_string=$(IFS=,; echo "${jaccard_arr[*]}")
names_string=$(IFS=,; echo "${names_arr[*]}")
python python_scripts/plot_radial_new.py --names "$names_string" --jaccard "$jaccard_string" --out "${pipe_out}/step5b_cross_species_jaccard.png"

echo "Step 5b has been completed."


mkdir -p "${step5_outdir}/6g"
echo "Finding enhancers specific to each species for each tissue... Outputs will go in ${step5_outdir}/6g"

# For tissue 1:
t1e_s1only="${step5_outdir}/6g/${species1}Only_${tissue1}_enhancers.bed"
t1e_s2only="${step5_outdir}/6g/${species2}Only_${tissue1}_enhancers.bed"
bedtools intersect -a $s1t1e_hal -b $s2t1e -v > $t1e_s1only
bedtools intersect -a $s2t1e -b $s1t1e_hal -v > $t1e_s2only

# For tissue 2:
t2e_s1only="${step5_outdir}/6g/${species1}Only_${tissue2}_enhancers.bed"
t2e_s2only="${step5_outdir}/6g/${species2}Only_${tissue2}_enhancers.bed"
bedtools intersect -a $s1t2e_hal -b $s2t2e -v > $t2e_s1only
bedtools intersect -a $s2t2e -b $s1t2e_hal -v > $t2e_s2only

echo "Step 5 has been completed!"



# Run step 6.
# for each input file, convert the bed to fasta (bash, not sbatch)
# then run motif_analysis.sh on it (which does use sbatch)
# Make subdirectories for each step within step 6.

mkdir -p "${step6_outdir}/6a"
echo "Running step 6a... Outputs will go in ${step6_outdir}/6a"
# Step 6a inputs are simply s1t1, s1t2, s2t1, s2t2
echo "Converting BED files to FASTA..."
# TODO: uncomment these 8 lines later
# bash convert_bed_to_fasta.sh $s1_genome "${s1t1}" "${step6_outdir}/6a/${species1}_${tissue1}.fasta"
# bash convert_bed_to_fasta.sh $s1_genome "${s1t2}" "${step6_outdir}/6a/${species1}_${tissue2}.fasta"
# bash convert_bed_to_fasta.sh $s2_genome "${s2t1}" "${step6_outdir}/6a/${species2}_${tissue1}.fasta"
# bash convert_bed_to_fasta.sh $s2_genome "${s2t2}" "${step6_outdir}/6a/${species2}_${tissue2}.fasta"

job_ids=()
# job_ids+=($(sbatch motif_analysis.sh "${step6_outdir}/6a/${species1}_${tissue1}.fasta" "${step6_outdir}/6a/${species1}_${tissue1}" $s1_meme | awk '{print $4}'))
# job_ids+=($(sbatch motif_analysis.sh "${step6_outdir}/6a/${species1}_${tissue2}.fasta" "${step6_outdir}/6a/${species1}_${tissue2}" $s1_meme | awk '{print $4}'))
# job_ids+=($(sbatch motif_analysis.sh "${step6_outdir}/6a/${species2}_${tissue1}.fasta" "${step6_outdir}/6a/${species2}_${tissue1}" $s2_meme | awk '{print $4}'))
# job_ids+=($(sbatch motif_analysis.sh "${step6_outdir}/6a/${species2}_${tissue2}.fasta" "${step6_outdir}/6a/${species2}_${tissue2}" $s2_meme | awk '{print $4}'))

echo "Submitted step 6a jobs with IDs: ${job_ids[*]}"


mkdir -p "${step6_outdir}/6b"
echo "Running step 6b... Outputs will go in ${step6_outdir}/6b"
echo "Converting BED files to FASTA..."
# TODO: uncomment these 8 lines later
# bash convert_bed_to_fasta.sh $s1_genome "${s1t1e}" "${step6_outdir}/6b/${species1}_${tissue1}_enhancers.fasta"
# bash convert_bed_to_fasta.sh $s1_genome "${s1t2e}" "${step6_outdir}/6b/${species1}_${tissue2}_enhancers.fasta"
# bash convert_bed_to_fasta.sh $s2_genome "${s2t1e}" "${step6_outdir}/6b/${species2}_${tissue1}_enhancers.fasta"
# bash convert_bed_to_fasta.sh $s2_genome "${s2t2e}" "${step6_outdir}/6b/${species2}_${tissue2}_enhancers.fasta"

job_ids=()

job_ids+=($(sbatch motif_analysis.sh "${step6_outdir}/6b/${species1}_${tissue1}_enhancers.fasta" "${step6_outdir}/6b/${species1}_${tissue1}_enhancers" $s1_meme | awk '{print $4}'))
job_ids+=($(sbatch motif_analysis.sh "${step6_outdir}/6b/${species1}_${tissue2}_enhancers.fasta" "${step6_outdir}/6b/${species1}_${tissue2}_enhancers" $s1_meme | awk '{print $4}'))
job_ids+=($(sbatch motif_analysis.sh "${step6_outdir}/6b/${species2}_${tissue1}_enhancers.fasta" "${step6_outdir}/6b/${species2}_${tissue1}_enhancers" $s2_meme | awk '{print $4}'))
job_ids+=($(sbatch motif_analysis.sh "${step6_outdir}/6b/${species2}_${tissue2}_enhancers.fasta" "${step6_outdir}/6b/${species2}_${tissue2}_enhancers" $s2_meme | awk '{print $4}'))

echo "Submitted step 6b jobs with IDs: ${job_ids[*]}"


# TODO: 6c (mkdir and echo it)

# TODO: 6d (mkdir and echo it)

# TODO: 6e (mkdir and echo it)

# TODO: 6f (mkdir and echo it)

# TODO: 6g (mkdir and echo it)


echo "All parts of step 6 have been submitted."
echo "You can check on the progress of step 6 by viewing the slurm-<job_id>.out file. If there are any errors, e.g. in file conversion, they will print to that file."
echo "Once these sbatch jobs have finished, the pipeline is complete!"