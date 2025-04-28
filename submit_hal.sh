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
# IMPORTANT: if you are running this on your own device, change the paths to match your own paths to the hal and halLiftover repositories
# These lines are key to getting halLiftover to run.
export PATH=/jet/home/kwang18/repos/hal/bin:${PATH}
export PYTHONPATH=/jet/home/kwang18/repos/halLiftover-postprocessing:${PYTHONPATH}
# give execute permissions to scripts
find /jet/home/kwang18/repos/halLiftover-postprocessing/ -type f -exec chmod a+x {} \; # change to match the directory that you put the halLiftover-postprocessing repo in

module load anaconda3
source activate hal

# It's important to allow 12 hours for halLiftover because it does take a long time
# To run all halLiftover jobs in parallel, just submit multiple jobs. 

# Usage(){
#     echo "Usage: $0 -p <path_to_halper_script> -b <input_bed_file> -o <output_directory> -s <source_species> -t <target_species> -c <alignment_file>" 
#     exit 1
# }

# example runs: use optimal peaks for all but the human ovary
# mouse pancreas:
# sbatch submit_hal.sh -b "/ocean/projects/bio230007p/ikaplow/MouseAtac/Pancreas/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz" -o ~/output/hal/Mouse/Pancreas -s Mouse -t Human
# mouse ovary:
# sbatch submit_hal.sh -b "/ocean/projects/bio230007p/ikaplow/MouseAtac/Ovary/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz" -o ~/output/hal/Mouse/Ovary -s Mouse -t Human
# human pancreas:
# sbatch submit_hal.sh -b "/ocean/projects/bio230007p/ikaplow/HumanAtac/Pancreas/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz" -o ~/output/hal/Human/Pancreas -s Human -t Mouse
# human ovary:
# sbatch submit_hal.sh -b "/ocean/projects/bio230007p/ikaplow/HumanAtac/Ovary/peak/idr_reproducibility/idr.conservative_peak.narrowPeak.gz" -o ~/output/hal/Human/Ovary -s Human -t Mouse

help_str="
Parameters:
  -h, --help:     Print out the manual
  -d, --dir:      halLiftover-postprocessing directory    Optional parameter
  -b, --bed:      Input BED or narrowpeak file            Mandatory parameter
  -o, --output:   Output directory                        Optional parameter
  -s, --source:   Source species                          Mandatory parameter
  -t, --target:   Target species                          Mandatory parameter
  -c, --align:    Alignment File                          Optional parameter
"

ARGS=`getopt -o d:b:o:s:t:c:h --long dir:,bed:,output:,source:,target:,align:,help -- "$@"`
if [ $? != 0 ]; then
   echo "Error parsing arguments"
   exit 1
fi

eval set -- "${ARGS}"

while true
do
  case "$1" in

    -h|--help)
      echo -e "$help_str"
      exit
      ;;

    -d|--dir)
      dir="$2"
      shift 2
      ;;

    -b|--bed)
      bed="$2"
      shift 2
      ;;

    -o|--output)
      out="$2"
      shift 2
      ;;

    -s|--source)
      source="$2"
      shift 2
      ;;

    -t|--target)
      target="$2"
      shift 2
      ;;

    -c|--align)
      align="$2"
      shift 2
      ;;

    --)
      shift
      break
      ;;

    *)
      echo "Internal error: unknown flags"
      exit 1
      ;;
  esac
done

# assign default values if needed
DEFAULT_DIR="$(pwd)/halLiftover-postprocessing"
DEFAULT_OUTPUT="$(pwd)/output"
DEFAULT_ALIGN="/ocean/projects/bio230007p/ikaplow/Alignments/10plusway-master.hal"

[ -z "$dir" ] && dir="$DEFAULT_DIR"
[ -z "$out" ] && out="$DEFAULT_OUTPUT"
[ -z "$align" ] && align="$DEFAULT_ALIGN"


# check output folder
if [ ! -d "$out" ]; then
    mkdir -p "$out" # -p flag to create all subdirectories at the same time if $out is a set of nested directories
    echo "Created output folder: $out"
fi

# check mandatory inputs
[ -z "$bed" ] && echo "No Input BED or narrowpeak file! Terminating..." && exit 1
[ -z "$source" ] && echo "No Input Source! Terminating..." && exit 1
[ -z "$target" ] && echo "No Input Target! Terminating..." && exit 1

exe="$dir/halper_map_peak_orthologs.sh"

# check the files
[ -f "$exe" ] || { echo "Cannot Locate halper_map_peak_orthologs! Terminating..."; exit 1; }
[ -x "$exe" ] || { echo "halper_map_peak_orthologs Not Executable! Terminating..."; exit 1; }
[ -f "$bed" ] || { echo "Cannot Locate BED or Narrowpeak File! Terminating..."; exit 1; }
[ -f "$align" ] || { echo "Cannot Locate Alignment File! Terminating..."; exit 1; }

# if input $bed is a .gz file, unzip it
if [[ "$bed" == *.gz ]]; then
  # Create ~/input directory if it doesn't exist
  # We unzip to the ~/input directory in case the original bed file's directory is read-only.
  mkdir -p ~/input

  # Unzip while keeping original file (-k) and force overwrite (-f)
  # Directly output to destination
  gunzip -k -f -c "$bed" > ~/input/peaks.narrowPeak # I tried preserving the source file's name, but it was causing issues

  # Update the bed variable
  bed=~/input/peaks.narrowPeak

  echo "Extracted the compressed BED to $bed"
 fi

# Unzip input $bed only if it is gzipped
# base_name=$(basename "$bed" .gz)

# if [[ "$bed" == *.gz ]]; then
#  gunzip -c "$bed" > "$out/$base_name"  # Decompress but keep original gzipped file
#  $bed="$out/$base_name" # created as a temporary file
# fi

# finally, run the halper script
"$exe" -b "$bed" -o "$out" -s "$source" -t "$target" -c "$align"

#rm -f "$out/$base_name" # if the temporary file was created, remove it; -f flag to ignore if nonexistent

echo "HAL analysis complete!"
