#!/bin/bash
#SBATCH --job-name=HALPER
#SBATCH --partition=RM-shared
#SBATCH --output=halper.out
#SBATCH --error=halper.err
#SBATCH --time=02:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=6G
#SBATCH -A bio230007p
##SBATCH --gres=gpu:1


halLiftover-postprocessing/halper_map_peak_orthologs.sh -b /ocean/projects/bio230007p/ikaplow/HumanAtac/Ovary/peak/rep1_vs_rep2/rep1_vs_rep2.idr0.05.bfilt.narrowPeak.gz -o output -s Human -t Mouse -c /ocean/projects/bio230007p/ikaplow/Alignments/10plusway-master.hal

