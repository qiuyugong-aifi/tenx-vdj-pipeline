#!/bin/bash

while getopts "i:k:o:" opt; do
  case $opt in
    i) input_dir="$OPTARG"
    ;;
    k) input_key="$OPTARG"
    ;;
    o) output_dir="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done


sed 1d ${input_key} | \
while IFS=, read -r SampleID BatchID HashTag PoolID; \
do cat ${input_dir}/${SampleID}*".csv" | \
awk -F',' -v OFS=',' '{ if(NR==1) { print $0 } else if($1!="barcode") { print $0 } }' > "${output_dir}/${BatchID}-${PoolID}_${SampleID}_filtered_contig.csv" ; \
done

BatchID=$(cat ${input_key} | awk -F, 'NR==2{print $2}')
PoolID=$(cat ${input_key} | awk -F, 'NR==2{print $4}')

cat ${input_dir}/multiplet*".csv" | awk -F',' -v OFS=',' '{ if(NR==1) { print $0 } else if($1!="barcodes") { print $0 } }' > "${output_dir}/${BatchID}-${PoolID}_multiplet_filtered_contig.csv"  

echo "Done"