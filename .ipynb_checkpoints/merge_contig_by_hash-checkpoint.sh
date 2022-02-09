#!/bin/bash



trap "exit 1" TERM
export TOP_PID=$$
  
  # Time statement function
  
  stm() {
    local ts=$(date +"%Y-%m-%d %H:%M:%S")
    echo "["$ts"] "$1
  }

# Elapsed time function

format_time() {
  local h=$(($1/60/60%24))
  local m=$(($1/60%60))
  local s=$(($1%60))
  
  printf "%02d:%02d:%02d" $h $m $s
}

elt() {
  local end_time="$(date -u +%s)"
  local split_diff="$(($end_time-$1))"
  local total_diff="$(($end_time-$2))"
  
  echo "Total time: " $(format_time $total_diff) "| Split time: " $(format_time $split_diff)
}

check_param() {
  local pflag=$1
  local pname=$2
  local pvar=$3
  
  if [ -z ${pvar} ]; then
  echo $(stm "ERROR ${pflag} ${pname}: parameter not set. Exiting.")
  kill -s TERM $TOP_PID 
  else
    echo  $(stm "PARAM ${pflag} ${pname}: ${pvar}")
  fi
}

pipeline_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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

echo $(stm "Done")