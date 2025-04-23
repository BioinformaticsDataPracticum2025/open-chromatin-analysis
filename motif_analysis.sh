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

# example run:
# sbatch ~/repos/open-chromatin-analysis/motif_analysis.sh ~/input/getfasta_test_output.fasta ~/output/meme_outdir_test $PROJECT/HOCOMOCOv11_full_HUMAN_mono_meme_format.meme

module load MEME-suite

# rename CLIs (which currently must be given in this exact order; someone can update the script so that it takes flags, like submit_hal.sh
input=$1 # path to the FASTA file that you want to perform motif analysis on
outdir=$2 # the name of the directory that you want MEME-ChIP to output to
ref_db=$3 # path to a MEME database of motifs


meme-chip -oc $outdir -db $ref_db -meme-nmotifs 3 -spamo-skip $input
