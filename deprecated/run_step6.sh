#!/bin/bash

# I wrote this hard-coded script to quickly run all analyses for step 6.
# I will later integrate step 6 into the pipeline.

# First, download the step6_inputs zipped folder from Google Drive, unzip it, and place it on the server.
project_dir="${HOME}/input"
dir="${project_dir}/step6_inputs" # turn this into a shortcut for easy reference

# for each set of inputs, convert from bed (or narrowPeak) to fasta, then run the MEME-ChIP job.
# I will go in order, but save 6a for the end because the files are huge and they might take a long time to convert from bed to fasta.

# Step 6b:
echo "Running step 6b"
job_ids=()


bash convert_bed_to_fasta.sh h "${dir}/6b/humanPancreas_enhancers.bed" "${dir}/6b/humanPancreas_enhancers.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6b/humanPancreas_enhancers.fasta" "${HOME}/output/meme/6b/humanPancreas_enhancers" h | awk '{print $4}'))


echo "Submitted step 6b jobs with IDs: ${job_ids[*]}"



# Step 6e: 
echo "Running step 6e"
job_ids=()


bash convert_bed_to_fasta.sh h "${dir}/6e/humanPancreasOnly_enhancers.bed" "${dir}/6e/humanPancreasOnly_enhancers.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6e/humanPancreasOnly_enhancers.fasta" "${HOME}/output/meme/6e/humanPancreasOnly_enhancers" h | awk '{print $4}'))


echo "Submitted step 6e jobs with IDs: ${job_ids[*]}"



# Step 6a:
echo "Running step 6a"
job_ids=()


bash convert_bed_to_fasta.sh h "${dir}/6a/humanPancreas.narrowPeak" "${dir}/6a/humanPancreas.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6a/humanPancreas.fasta" "${HOME}/output/meme/6a/humanPancreas" h | awk '{print $4}'))

bash convert_bed_to_fasta.sh m "${dir}/6a/mouseOvary.narrowPeak" "${dir}/6a/mouseOvary.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6a/mouseOvary.fasta" "${HOME}/output/meme/6a/mouseOvary" m | awk '{print $4}'))


echo "Submitted step 6a jobs with IDs: ${job_ids[*]}"
