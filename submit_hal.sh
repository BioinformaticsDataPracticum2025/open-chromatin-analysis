#!/bin/bash
#SBATCH --job-name=HALPER
#SBATCH --partition=RM-shared
#SBATCH --output=halper.out
#SBATCH --error=halper.err
#SBATCH --time=12:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=6G
#SBATCH -A bio230007p
##SBATCH --gres=gpu:1

# hal and HALPER; installation documentation says you have to set these manually, without ~
# I think that adding these lines was key to getting halLiftover to run, because the job no longer finishes within seconds
export PATH=/jet/home/kwang18/repos/hal/bin:${PATH}
export PYTHONPATH=/jet/home/kwang18/repos/halLiftover-postprocessing:${PYTHONPATH}

source activate base
conda activate hal

# It's important to allow 12 hours for halLiftover because it does take a long time
cd ~ # ensure that the output directory ends up in the home directory; when running things on a cluster, this is important

# give execute permissions to scripts
find ~/repos/halLiftover-postprocessing/ -type f -exec chmod a+x {} \;

outdir="output/hal/Human/Ovary" # take this as CLI or parse this from CLI later
mkdir -p $outdir # use -p flag so there's no error if the directory already exists, and to make subdirectories all at the same time

peak="/ocean/projects/bio230007p/ikaplow/HumanAtac/Ovary/peak/rep1_vs_rep2/rep1_vs_rep2.idr0.05.bfilt.narrowPeak.gz"
# peak could be a CLI, but I'm hard-coding it for now

mkdir -p input # make an input directory for convenience
yes | cp $peak ~/input/peaks.narrowPeak.gz # for convenience, copy the peaks file into the input directory under a known name
gunzip -f ~/input/peaks.narrowPeak.gz # The halLiftover documentation claimed that .gz files were okay, but you do need to unzip
# use yes command or -f to overwrite files if they already exist

# Line by line breakdown of commands:
# 1: Script reference is an absolute path from the home directory to ensure we can find it
# It assumes that you've cloned the halper repository to a subdirectory called repos.
# 2: input peak file as .narrowPeak or .bed; should make into a CLI. Supposedly halLiftover will work on .gz files, but if not, then extract it before running 
# 3: out diretory, already set up as a variable. Later, parse it from CLI.
# 4: source species, i.e. the species the .narrowPeak or .bed file came from. Should make into a CLI. Only accept Human or Mouse; all others should give an error.
# 5: target species. Could use a conditional: if source species is Human, pick Mouse, and vice versa.
# 6: path to Cactus alignment file; make into a CLI.

~/repos/halLiftover-postprocessing/halper_map_peak_orthologs.sh \
	-b ~/input/peaks.narrowPeak \
	-o $outdir \
	-s Human \
	-t Mouse \
	-c /ocean/projects/bio230007p/ikaplow/Alignments/10plusway-master.hal

echo "HAL analysis complete!"
