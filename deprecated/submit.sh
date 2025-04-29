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

# Usage(){
#     echo "Usage: $0 -p <path_to_halper_script> -b <input_bed_file> -o <output_directory> -s <source_species> -t <target_species> -c <alignment_file>" 
#     exit 1
# }

DEFAULT_DIR="$(pwd)/halLiftover-postprocessing"
DEFAULT_OUTPUT="$(pwd)/output"
DEFAULT_ALIGN="/ocean/projects/bio230007p/ikaplow/Alignments/10plusway-master.hal"

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

# check output folder
if [ -z "$out" ]; then
  if [ ! -d "$DEFAULT_OUTPUT" ]; then
    mkdir "$DEFAULT_OUTPUT"
    echo "Created output folder: $DEFAULT_OUTPUT"
  fi 
fi

# assign default values 
[ -z "$dir" ] && dir="$DEFAULT_DIR"
[ -z "$out" ] && out="$DEFAULT_OUTPUT"
[ -z "$align" ] && align="$DEFAULT_ALIGN"

# check mandatory inputs
[ ! -d "$out" ] && { mkdir "$out"; echo "Created output folder: $out"; }
[ -z "$bed" ] && echo "No Input BED or narrowpeak file! Terminating..." && exit 1
[ -z "$source" ] && echo "No Input Source! Terminating..." && exit 1
[ -z "$target" ] && echo "No Input Target! Terminating..." && exit 1

exe="$dir/halper_map_peak_orthologs.sh"

# check the files 
[ -f "$exe" ] || { echo "Cannot Locate halper_map_peak_orthologs! Terminating..."; exit 1; }
[ -x "$exe" ] || { echo "halper_map_peak_orthologs Not Executable! Terminating..."; exit 1; }
[ -f "$bed" ] || { echo "Cannot Locate BED or Narrowpeak File! Terminating..."; exit 1; }
[ -f "$align" ] || { echo "Cannot Locate Alignment File! Terminating..."; exit 1; }


# halLiftover-postprocessing/halper_map_peak_orthologs.sh -b /ocean/projects/bio230007p/ikaplow/HumanAtac/Ovary/peak/rep1_vs_rep2/rep1_vs_rep2.idr0.05.bfilt.narrowPeak.gz -o output -s Human -t Mouse -c /ocean/projects/bio230007p/ikaplow/Alignments/10plusway-master.hal
"$exe" -b "$bed" -o "$out" -s "$source" -t "$target" -c "$align"

