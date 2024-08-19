#!/bin/bash

# Define arrays with the vertex indices
ist1s=(1 1 1 1 1 1 1 1 1 1)
ist2s=(1 1 2 4 8 17 38 60 152 352)
jst1s=(1 1 1 1 1 1 1 1 1 1)
jst2s=(60 125 150 170 185 200 200 250 250 250)
kst1s=(1 1 1 1 1 1 1 1 1 1)
kst2s=(25 28 25 25 25 25 25 28 25 25)


# Output directory for the log files
output_dir="./output_logs"
mkdir -p "$output_dir"


for (( i=0; i<${#ist1s[@]}; i++ )); do
  cd projects/GYRE4/

#   echo "Before modification:"
#   cat namelist_GYRE4.in

  # Generate new namelist_GYRE4.in by replacing vertex indices
	sed -i -e "s/^\(\s*ist1\s*=\s*\)[^,]*,/\1${ist1s[$i]},/" \
		-e "s/^\(\s*ist2\s*=\s*\)[^,]*,/\1${ist2s[$i]},/" \
		-e "s/^\(\s*jst1\s*=\s*\)[^,]*,/\1${jst1s[$i]},/" \
		-e "s/^\(\s*jst2\s*=\s*\)[^,]*,/\1${jst2s[$i]},/" \
		-e "s/^\(\s*kst1\s*=\s*\)[^,]*,/\1${kst1s[$i]},/" \
		-e "s/^\(\s*kst2\s*=\s*\)[^,]*,/\1${kst2s[$i]},/" namelist_GYRE4.in




  # Echo the current vertex indices
    # echo "ist1=${ist1s[$i]}, ist2=${ist2s[$i]}, jst1=${jst1s[$i]}, jst2=${jst2s[$i]}, kst1=${kst1s[$i]}, kst2=${kst2s[$i]}"

#   echo "After modification:"
#   cat namelist_GYRE4.in

#   # Stop 
#   exit 1

  # Recompile tracmass
  cd ../../
  make clean && make

  # Run tracmass and capture the output using `time`
#   { /usr/bin/time -v ./runtracmass 2>&1; } 2> temp_time_output.txt
	{ /usr/bin/time -v ./runtracmass ; } > temp_time_output.txt 2>&1

  # Generate output file name and handle duplicates
  output_file="$output_dir/tracmass_output"
  if [[ -e "$output_file.txt" ]] || [[ -e "$output_file" ]]; then
    counter=1
    while [[ -e "${output_file}_${counter}.txt" ]]; do
      let counter++
    done
    output_file="${output_file}_${counter}.txt"
  else
    output_file="${output_file}.txt"
  fi

  # Extract the relevant data and save it to a file
  grep -A 22 "Command being timed" temp_time_output.txt > "$output_file"

done

# Cleanup
rm temp_time_output.txt
