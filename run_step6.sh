#!/bin/bash

# I wrote this hard-coded script to quickly run all analyses for step 6.
# I will later integrate step 6 into the pipeline.

# First, download the step6_inputs zipped folder from Google Drive, unzip it, and place it on the server.
project_dir="${HOME}/input" # this is where I'm placing my folder
dir="${project_dir}/step6_inputs" # turn this into a shortcut for easy reference

# for each set of inputs, convert from bed (or narrowPeak) to fasta, then run the MEME-ChIP job.
# I will go in order, but save 6a for the end because the files are huge and they might take a long time to convert from bed to fasta.

# Step 6b:
echo "Running step 6b"
job_ids=()

bash convert_bed_to_fasta.sh h "${dir}/6b/humanOvary_enhancers.bed" "${dir}/6b/humanOvary_enhancers.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6b/humanOvary_enhancers.fasta" "${HOME}/output/meme/6b/humanOvary_enhancers" h | awk '{print $4}'))

bash convert_bed_to_fasta.sh h "${dir}/6b/humanPancreas_enhancers.bed" "${dir}/6b/humanPancreas_enhancers.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6b/humanPancreas_enhancers.fasta" "${HOME}/output/meme/6b/humanPancreas_enhancers" h | awk '{print $4}'))

bash convert_bed_to_fasta.sh m "${dir}/6b/mouseOvary_enhancers.bed" "${dir}/6b/mouseOvary_enhancers.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6b/mouseOvary_enhancers.fasta" "${HOME}/output/meme/6b/mouseOvary_enhancers" m | awk '{print $4}'))

bash convert_bed_to_fasta.sh m "${dir}/6b/mousePancreas_enhancers.bed" "${dir}/6b/mousePancreas_enhancers.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6b/mousePancreas_enhancers.fasta" "${HOME}/output/meme/6b/mousePancreas_enhancers" m | awk '{print $4}'))

echo "Submitted step 6b jobs with IDs: ${job_ids[*]}"


# Step 6c:
echo "Running step 6c"
job_ids=()

bash convert_bed_to_fasta.sh h "${dir}/6c/humanOvary_promoters.bed" "${dir}/6c/humanOvary_promoters.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6c/humanOvary_promoters.fasta" "${HOME}/output/meme/6c/humanOvary_promoters" h | awk '{print $4}'))

bash convert_bed_to_fasta.sh h "${dir}/6c/humanPancreas_promoters.bed" "${dir}/6c/humanPancreas_promoters.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6c/humanPancreas_promoters.fasta" "${HOME}/output/meme/6c/humanPancreas_promoters" h | awk '{print $4}'))

bash convert_bed_to_fasta.sh m "${dir}/6c/mouseOvary_promoters.bed" "${dir}/6c/mouseOvary_promoters.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6c/mouseOvary_promoters.fasta" "${HOME}/output/meme/6c/mouseOvary_promoters" m | awk '{print $4}'))

bash convert_bed_to_fasta.sh m "${dir}/6c/mousePancreas_promoters.bed" "${dir}/6c/mousePancreas_promoters.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6c/mousePancreas_promoters.fasta" "${HOME}/output/meme/6c/mousePancreas_promoters" m | awk '{print $4}'))

echo "Submitted step 6c jobs with IDs: ${job_ids[*]}"


# Step 6d:
echo "Running step 6d"
job_ids=()

bash convert_bed_to_fasta.sh h "${dir}/6d/human_crossTissue_enhancers.bed" "${dir}/6d/human_crossTissue_enhancers.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6d/human_crossTissue_enhancers.fasta" "${HOME}/output/meme/6d/human_crossTissue_enhancers" h | awk '{print $4}'))

bash convert_bed_to_fasta.sh m "${dir}/6d/mouse_crossTissue_enhancers.bed" "${dir}/6d/mouse_crossTissue_enhancers.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6d/mouse_crossTissue_enhancers.fasta" "${HOME}/output/meme/6d/mouse_crossTissue_enhancers" m | awk '{print $4}'))

echo "Submitted step 6d jobs with IDs: ${job_ids[*]}"


# Step 6e: 
echo "Running step 6e"
job_ids=()

bash convert_bed_to_fasta.sh h "${dir}/6e/humanOvaryOnly_enhancers.bed" "${dir}/6e/humanOvaryOnly_enhancers.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6e/humanOvaryOnly_enhancers.fasta" "${HOME}/output/meme/6e/humanOvaryOnly_enhancers" h | awk '{print $4}'))

bash convert_bed_to_fasta.sh h "${dir}/6e/humanPancreasOnly_enhancers.bed" "${dir}/6e/humanPancreasOnly_enhancers.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6e/humanPancreasOnly_enhancers.fasta" "${HOME}/output/meme/6e/humanPancreasOnly_enhancers" h | awk '{print $4}'))

bash convert_bed_to_fasta.sh m "${dir}/6e/mouseOvaryOnly_enhancers.bed" "${dir}/6e/mouseOvaryOnly_enhancers.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6e/mouseOvaryOnly_enhancers.fasta" "${HOME}/output/meme/6e/mouseOvaryOnly_enhancers" m | awk '{print $4}'))

bash convert_bed_to_fasta.sh m "${dir}/6e/mousePancreasOnly_enhancers.bed" "${dir}/6e/mousePancreasOnly_enhancers.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6e/mousePancreasOnly_enhancers.fasta" "${HOME}/output/meme/6e/mousePancreasOnly_enhancers" m | awk '{print $4}'))

echo "Submitted step 6e jobs with IDs: ${job_ids[*]}"


# Step 6f:
# (in mouse coordinates for this cross-species intersection)
echo "Running step 6f"
job_ids=()

bash convert_bed_to_fasta.sh m "${dir}/6f/bothSpecies_ovary_enhancers.bed" "${dir}/6f/bothSpecies_ovary_enhancers.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6f/bothSpecies_ovary_enhancers.fasta" "${HOME}/output/meme/6f/bothSpecies_ovary_enhancers" m | awk '{print $4}'))

bash convert_bed_to_fasta.sh m "${dir}/6f/bothSpecies_pancreas_enhancers.bed" "${dir}/6f/bothSpecies_pancreas_enhancers.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6f/bothSpecies_pancreas_enhancers.fasta" "${HOME}/output/meme/6f/bothSpecies_pancreas_enhancers" m | awk '{print $4}'))

echo "Submitted step 6f jobs with IDs: ${job_ids[*]}"

# Step 6g:
# (in mouse coordinates for this cross-species intersection)
echo "Running step 6e"
job_ids=()

bash convert_bed_to_fasta.sh m "${dir}/6g/humanOnly_ovary_enhancers.bed" "${dir}/6g/humanOnly_ovary_enhancers.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6g/humanOnly_ovary_enhancers.fasta" "${HOME}/output/meme/6g/humanOnly_ovary_enhancers" m | awk '{print $4}'))

bash convert_bed_to_fasta.sh m "${dir}/6g/humanOnly_pancreas_enhancers.bed" "${dir}/6g/humanOnly_pancreas_enhancers.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6g/humanOnly_pancreas_enhancers.fasta" "${HOME}/output/meme/6g/humanOnly_pancreas_enhancers" m | awk '{print $4}'))

# note the misspelling of "ovary" in the input bed
bash convert_bed_to_fasta.sh m "${dir}/6g/mouseOnly_ovar_enhancers.bed" "${dir}/6g/mouseOnly_ovary_enhancers.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6g/mouseOnly_ovary_enhancers.fasta" "${HOME}/output/meme/6g/mouseOnly_ovary_enhancers" m | awk '{print $4}'))

bash convert_bed_to_fasta.sh m "${dir}/6g/mouseOnly_pancreas_enhancers.bed" "${dir}/6g/mouseOnly_pancreas_enhancers.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6g/mouseOnly_pancreas_enhancers.fasta" "${HOME}/output/meme/6g/mouseOnly_pancreas_enhancers" m | awk '{print $4}'))

echo "Submitted step 6g jobs with IDs: ${job_ids[*]}"

# Step 6a:
echo "Running step 6a"
job_ids=()

bash convert_bed_to_fasta.sh h "${dir}/6a/humanOvary.narrowPeak" "${dir}/6a/humanOvary.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6a/humanOvary.fasta" "${HOME}/output/meme/6a/humanOvary" h | awk '{print $4}'))

bash convert_bed_to_fasta.sh h "${dir}/6a/humanPancreas.narrowPeak" "${dir}/6a/humanPancreas.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6a/humanPancreas.fasta" "${HOME}/output/meme/6a/humanPancreas" h | awk '{print $4}'))

bash convert_bed_to_fasta.sh m "${dir}/6a/mouseOvary.narrowPeak" "${dir}/6a/mouseOvary.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6a/mouseOvary.fasta" "${HOME}/output/meme/6a/mouseOvary" m | awk '{print $4}'))

bash convert_bed_to_fasta.sh m "${dir}/6a/mousePancreas.narrowPeak" "${dir}/6a/mousePancreas.fasta"
job_ids+=($(sbatch motif_analysis.sh "${dir}/6a/mousePancreas.fasta" "${HOME}/output/meme/6a/mousePancreas" m | awk '{print $4}'))

echo "Submitted step 6a jobs with IDs: ${job_ids[*]}"