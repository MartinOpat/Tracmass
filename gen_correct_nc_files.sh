#!/bin/bash

# Directory containing the original NetCDF files
input_dir="$HOME/Lagrangian-fluid-simulation-for-Android/simulation/data/daily_netcdf"
# Directory to store the modified NetCDF files
output_dir="$HOME/Lagrangian-fluid-simulation-for-Android/simulation/data/modified_netcdf"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop over all NetCDF files in the input directory
for file in "$input_dir"/hydrodynamic_*.nc; do
    # Extract filename without path
    filename=$(basename "$file")
    # Define output filename
    output_file="$output_dir/$filename"

    # Extract the first time step and remove the time dimension using ncks and ncwa
    ncks -O -d time,0 "$file" temp.nc
    ncwa -O -a time temp.nc "$output_file"
    rm temp.nc  # Clean up intermediate file

    echo "Processed $filename"
done

echo "All files processed successfully."
