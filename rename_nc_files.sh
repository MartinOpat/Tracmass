#!/bin/bash

# Directory where the files are located
directory="$HOME/Lagrangian-fluid-simulation-for-Android/simulation/data/modified_netcdf"

# Base start date parameters
start_year=2000
start_month=1
start_day=1

# Loop to process each file
for i in {0..364}; do  # Assuming you have 365 files, adjust if needed
    # Calculate current month and day
    current_month=$(( (i / 30) + 1 ))
    current_day=$(( (i % 30) + 1 ))

    # Format current month and day
    formatted_month=$(printf "%02d" $current_month)
    formatted_day=$(printf "%02d" $current_day)

    # Construct the date string
    date_string="${formatted_day}${formatted_month}${start_year}"

    # Build old and new file names
    old_filename="hydrodynamic_W_d$(printf "%04d" $i).nc"
    new_filename="hydrodynamic_W_d${date_string}.nc"

    # Full path for old and new filenames
    old_filepath="$directory/$old_filename"
    new_filepath="$directory/$new_filename"

    # Rename the file
    if [ -f "$old_filepath" ]; then
        mv "$old_filepath" "$new_filepath"
        echo "Renamed $old_filepath to $new_filepath"
    else
        echo "File $old_filepath does not exist"
    fi
done

echo "All applicable files have been renamed."
