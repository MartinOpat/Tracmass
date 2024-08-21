#!/bin/bash

# Define arrays with the vertex indices
ist1s=(1 1 1 1 1 1 1 1 1 1 1)
ist2s=(1 1 2 4 8 17 38 60 152 352 500)
jst1s=(1 1 1 1 1 1 1 1 1 1 1)
jst2s=(60 125 150 170 185 200 200 250 250 250 250)
kst1s=(1 1 1 1 1 1 1 1 1 1 1)
kst2s=(25 28 25 25 25 25 25 28 25 25 20)
partquant=(1 1 1 1 1 1 1 1 1 1 2)

# Output directory for the log files
output_dir="./output_logs"
mkdir -p "$output_dir"

for (( i=0; i<${#ist1s[@]}; i++ )); do
  cd projects/GYRE4/

  # Generate new namelist_GYRE4.in by replacing vertex indices
  sed -i -e "s/^\(\s*partquant\s*=\s*\)[^,]*,/\1${partquant[$i]},/" \
         -e "s/^\(\s*ist1\s*=\s*\)[^,]*,/\1${ist1s[$i]},/" \
         -e "s/^\(\s*ist2\s*=\s*\)[^,]*,/\1${ist2s[$i]},/" \
         -e "s/^\(\s*jst1\s*=\s*\)[^,]*,/\1${jst1s[$i]},/" \
         -e "s/^\(\s*jst2\s*=\s*\)[^,]*,/\1${jst2s[$i]},/" \
         -e "s/^\(\s*kst1\s*=\s*\)[^,]*,/\1${kst1s[$i]},/" \
         -e "s/^\(\s*kst2\s*=\s*\)[^,]*,/\1${kst2s[$i]},/" \
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

done

# Cleanup
rm temp_time_output.txt
