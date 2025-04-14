# Scripts Documentation

This document provides detailed usage information for the scripts.

---

## bedtool.sh

This script offers a convenient way to perform multiple bedtools intersection analysis with user-customizable options.

### Usage
```bash
. bedtools.sh path_to_input_file
```

### Input File Format
The input file should be a tab-separated text file containing 5 columns. Below is an example file format:

**Example: `example_input.txt`**
```txt
# comment the line with #
file_path_to_peak_file_A     file_path_to_peak_file_B     bedfile_output_path     y     file_A_B

# second pair
file_path_to_peak_file_C     file_path_to_peak_file_D     bedfile_output_path     n     file_C_D
```
- **Column 4:** Reporting flag:  
 `y` corresponds to `-u` flag for bedtools, meaning unique overlap report   
 `n` corresponds to `-v` flag for bedtools, meaning non-overlap report
- **Column 5:** The label that will appear in the generated plot 


### Outputs