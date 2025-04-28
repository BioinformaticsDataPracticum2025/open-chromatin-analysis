#!/bin/bash
#SBATCH --job-name=MEME-suite
#SBATCH --partition=RM-shared
#SBATCH --output=halper.out
#SBATCH --error=halper.err
#SBATCH --time=36:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=6G
#SBATCH -A bio230007p
##SBATCH --gres=gpu:1

# Received help from Ziyun

#================================================================================================
# Inputs:
# $1: $input fasta in which to find motifs.
# $2: $outdir in which the results will be written.
# NOTE: Always supply a new output_dir to avoid overwriting previous results.
# $3: ref_db, which is either h, m, or a path to a file that ends in .meme. Throws an error otherwise.

# Output: Look for the motifs and E-values in the summary.tsv file in $outdir.

# example run:
# sbatch ~/repos/open-chromatin-analysis/motif_analysis.sh ~/input/getfasta_test_output.fasta ~/output/meme_outdir_test h


# SETUP:
# First: convert bed file of peaks to a fasta file using bedtools getfasta 
# Please refer to convert_bed_to_fasta.sh.


# Second: copy over the .meme databases from another directory.
# Ziyun recommended using these .meme files.
# Note that these are NOT in the directory that the $PROJECT directory is in.
#================================================================================================


# Copy human database if not already present 
if [[ ! -f "$PROJECT/HOCOMOCOv11_full_HUMAN_mono_meme_format.meme" ]]; then
    echo "Copying human motif database..."
    cp /ocean/projects/bio200034p/ikaplow/MotifData/motif_databases/HUMAN/HOCOMOCOv11_full_HUMAN_mono_meme_format.meme $PROJECT/HOCOMOCOv11_full_HUMAN_mono_meme_format.meme
fi

if [[ ! -f "$PROJECT/HOCOMOCOv11_full_MOUSE_mono_meme_format.meme" ]]; then
    echo "Copying mouse motif database..."
    cp /ocean/projects/bio200034p/ikaplow/MotifData/motif_databases/MOUSE/HOCOMOCOv11_full_MOUSE_mono_meme_format.meme $PROJECT/HOCOMOCOv11_full_MOUSE_mono_meme_format.meme
fi


# Now we are ready to run MEME-suite. It seems like CentriMo doesn't work, but that's fine because we get motifs from MEME and STREME.

module load MEME-suite

# rename CLIs (which currently must be given in this exact order; someone can update the script so that it takes flags, like submit_hal.sh
input=$1        # Input FASTA file 
outdir=$2       # Output directory for MEME-ChIP

if [[ "$3" == "h" ]]; then
    ref_db="$PROJECT/HOCOMOCOv11_full_HUMAN_mono_meme_format.meme"
elif [[ "$3" == "m" ]]; then
    ref_db="$PROJECT/HOCOMOCOv11_full_MOUSE_mono_meme_format.meme"
elif [[ "$3" == *.meme ]]; then
    ref_fasta="$3" # path to a MEME database of motifs
else
    echo "Invalid third argument: must be 'h', 'm', or a .meme file."
    exit 1
fi

# Run MEME-ChIP
meme-chip -oc $outdir -db $ref_db -meme-nmotifs 3 -spamo-skip $input
