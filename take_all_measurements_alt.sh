#!/bin/bash

# Define arrays with the vertex indices
partquant=(1500 3500 7500 17000 37000 85000 190000 420000 950000 2200000 5000000)
# partquant=(950000 2200000 5000000)  # Leftover

# Output directory for the log files
output_dir="./output_logs"
mkdir -p "$output_dir"

for (( i=0; i<${#partquant[@]}; i++ )); do
  cd projects/GYRE4/

  # Generate new namelist_GYRE4.in by replacing vertex indices
  sed -i -e "s/^\(\s*partquant\s*=\s*\)[^,]*,/\1${partquant[$i]},/" \
         namelist_GYRE4.in

  # Recompile tracmass
  cd ../../
  make clean && make

  # Generate output file name and handle duplicates
  output_file="$output_dir/tracmass_output"
  if [[ -e "$output_file.txt" ]] || [[ -e "$output_file" ]]; then
    counter=1
    while [[ -e "${output_file}_${counter}.txt" ]]; do
      ((counter++))
    done
    output_file="${output_file}_${counter}.txt"
  else
    output_file="${output_file}.txt"
  fi

  # Run tracmass and capture the output using `time`, repeat three times
  for j in {1..3}; do
    { nice -n 20 /usr/bin/time -v ./runtracmass ; } > temp_time_output.txt 2>&1
    # Extract the relevant data and append it to the same file
    echo "Measurement $j:" >> "$output_file"
    grep -A 22 "Command being timed" temp_time_output.txt >> "$output_file"
  done

  # Store number of lines from TRACMASS_run.csv divided by partquant[i]
  # in the output file
  if [ -r TRACMASS_run.csv ]; then
      num_lines=$(wc -l < TRACMASS_run.csv)
      echo "HEEEEEERE: $num_lines"
  else
      echo "File TRACMASS_run.csv not found or is not readable"
  fi

  echo "HEEEEEERE: $num_lines"
  echo "Number of steps: $((num_lines / partquant[i]))" >> "$output_file"

done

# Cleanup
rm temp_time_output.txt
