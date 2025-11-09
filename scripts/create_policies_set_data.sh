#!/bin/bash

# Define the path to your input file

# az policy set-definition list --query '[].{Name: name, Displayname: displayName, Description: description }' -o tsv > ./initiatives_list.txt
#tr '\t' '\n' < ./initiatives_list.txt
INPUT_FILE="/home/andrea/azcli_policies_data/initiatives_list.txt"

# Loop through each line of the file
while IFS= read -r line; do
  # Process each line here
  # echo "Processing line: $line"
  echo "$line" | cut -f1
  echo "$line" | cut -f2
  echo "$line" | cut -f3
  echo "---------------------"

  # You can perform any other commands or operations with "$line"
done < "$INPUT_FILE"
