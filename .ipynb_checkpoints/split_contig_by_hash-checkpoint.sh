
#!/bin/bash
#c : hto file 
#i : input contig file 
#o : ouput directory
#w : well id

# Trap exit 1 to allow termination within the check_param() function.
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

# Parse command-line arguments


while getopts c:i:w:o: flag
do
    case "${flag}" in
        c) in_category=${OPTARG};;
        i) in_contig=${OPTARG};;
        w) well_id=${OPTARG};;
        o) output_dir=${OPTARG};;
        

    esac
done

echo $(stm "START TCR/BCR spliting by hash")
echo $(check_param "-c" "Input HTO Category" ${in_category})
echo $(check_param "-i" "Input Contig file" ${in_contig})
echo $(check_param "-o" "Output Directory" ${output_dir})
echo $(check_param "-w" "Well ID" ${well_id})
total_start_time="$(date -u +%s)"


extension="${in_contig##*.}"

if [[ $extension == *"csv" ]]; then
    gzip -fk ${in_contig} >${in_contig}.gz
    header="$(zcat "${in_contig}.gz" | head -n 1)"
    echo $(stm "Creating Files")
    zcat ${in_category} | awk -F',' -v hdr=${header} -v w=${well_id} -v out=${output_dir} '{ if(NF==4 && $2=="singlet" && !seen[$4]++) { print hdr > out"/"$4"_"w"_filtered_contig.csv" } }'; 
    echo $(stm "Splitting")

    zcat ${in_category} ${in_contig}.gz| awk -F',' -v w=${well_id} -v out=${output_dir} '{ if(NF<=4) { if ($2 == "singlet") { a[$1"-1"]=$4"_" } else { a[$1"-1"]=$4 } } else if (NF>4) { if (a[$1] ~ /_$/) { print $0 >> out"/"a[$1]w"_filtered_contig.csv"; close(file) } else { print $0 >> out"/multiplet_"w"_filtered_contig.csv"; close(file) } } }'
fi

if [[ $extension == *"csv.gz" ]]; then 
    header="$(zcat "${in_contig}" | head -n 1)"
    echo $(stm "Creating Files")
    zcat ${in_category} | awk -F',' -v hdr=${header} -v w=${well_id} -v out=${output_dir} '{ if(NF==4 && $2=="singlet" && !seen[$4]++) { print hdr > out"/"$4"_"w"_filtered_contig_airr.csv" } }'
    echo $(stm "Splitting")

    zcat ${in_category} ${in_contig}| awk -F',' -v w=${well_id} -v out=${output_dir} '{ if(NF<=4) { if ($2 == "singlet") { a[$1"-1"]=$4"_" } else { a[$1"-1"]=$4 } } else if (NF>4) { if (a[$1] ~ /_$/) { print $0 >> out"/"a[$1]w"_filtered_contig_airr.csv"; close(file) } else { print $0 >> out"/multiplet_"w"_filtered_contig_airr.csv"; close(file) } } }'
fi

split_start_time="$(date -u +%s)"
echo $(stm "$(elt $split_start_time $total_start_time)" )
echo $(stm "END TCR/BCR Contig Spliting by Hash")