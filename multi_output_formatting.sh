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

# Parse command-line arguments
#d : directory of cellrnager Multi output 
#b : batch id  
#w : well id

while getopts d:b:w: flag
do
    case "${flag}" in
        d) d=${OPTARG};;
        b) b=${OPTARG};;
        w) w=${OPTARG};;
        

    esac
done



echo $(stm "START TCR/BCR spliting by hash")
echo $(check_param "-c" "Input Cellranger Multi Output" ${d})
echo $(check_param "-b" "Batch ID" ${b})
echo $(check_param "-w" "Well ID" ${w})
total_start_time="$(date -u +%s)"

echo $(stm "Batch ID : ${b}   Well ID : ${w}" ) 
echo $(stm "Processing Summary Metrics" ) 

awk -F'"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(",", "", $i) } 1' ${d}/metrics_summary.csv | awk -F, '{print $2","$5","$6}'|sed -e 's/\s\+/_/g'|awk -F, -v d=$d 'NR==1 {header = $0; next} !header_printed[$1]++ {print header > d$1"_summary.csv"} {print > d$1"_summary_temp.csv"}'



cat ${d}/Gene_Expression_summary_temp.csv |awk -F, '{print $2","$3}'|csvtool transpose - |cut -d, -f1- > ${d}/${b}_${w}_Gene_Expression_summary.csv
cat ${d}/VDJ_T_summary_temp.csv |awk -F, '{print $2","$3}'|csvtool transpose - |cut -d, -f1- > ${d}/${b}-${w}_VDJ_T_summary.csv
cat ${d}/VDJ_B_summary_temp.csv |awk -F, '{print $2","$3}'|csvtool transpose - |cut -d, -f1- > ${d}/${b}-${w}_VDJ_B_summary.csv

rm ${d}/Gene_Expression_summary_temp.csv
rm ${d}/VDJ_T_summary_temp.csv
rm ${d}/VDJ_B_summary_temp.csv

echo $(stm "Done")

echo $(stm "Processing AIRR and Filter Contig file")

sed 's/\t/,/g' ${d}/vdj_b/airr_rearrangement.tsv > ${d}/vdj_b/temp.csv
sed 's/\t/,/g' ${d}/vdj_t/airr_rearrangement.tsv > ${d}/vdj_t/temp.csv

paste -d, ${d}/vdj_b/filtered_contig_annotations.csv ${d}vdj_b/temp.csv > ${d}/vdj_b/temp_combined.csv
paste -d, ${d}/vdj_t/filtered_contig_annotations.csv ${d}vdj_t/temp.csv> ${d}/vdj_t/temp_combined.csv

awk -F, '{print $1","$2","$3","$4","$5","$6","$7","$40","$8","$42","$9","$44","$10","$46","$11","$12","$13","$14","$15","$16","$17","$18","$19","$20","$21","$22","$23","$24","$25","$26","$27","$28","$29","$30","$47","$48","$49","$50","$51","$52","$53","$54","$55","$56","$57","$58","$59","$60}' ${d}/vdj_b/temp_combined.csv >${d}/vdj_b/temp_combined_rearranged.csv

awk -F, '{print $1","$2","$3","$4","$5","$6","$7","$40","$8","$42","$9","$44","$10","$46","$11","$12","$13","$14","$15","$16","$17","$18","$19","$20","$21","$22","$23","$24","$25","$26","$27","$28","$29","$30","$47","$48","$49","$50","$51","$52","$53","$54","$55","$56","$57","$58","$59","$60}' ${d}/vdj_t/temp_combined.csv >${d}/vdj_t/temp_combined_rearranged.csv


#add well id 
echo $(stm "Adding Well ID")

awk -v w=$w -F"," 'BEGIN {OFS = ","} FNR==1{$(NF+1)="Well_ID"} FNR>1{$(NF+1)=w;} 1' ${d}/vdj_t/temp_combined_rearranged.csv >${d}/vdj_t/temp_${b}-${w}Filtered_Contig_Reformated.csv 
awk -v w=$w -F"," 'BEGIN {OFS = ","} FNR==1{$(NF+1)="Well_ID"} FNR>1{$(NF+1)=w;} 1' ${d}/vdj_b/temp_combined_rearranged.csv >${d}/vdj_b/temp_${b}-${w}Filtered_Contig_Reformated.csv 

awk -v w=$w -F"," 'BEGIN {OFS = ","} FNR==1{$(NF+1)="Well_ID"} FNR>1{$(NF+1)=w;} 1' ${d}/vdj_t/filtered_contig_annotations.csv >${d}/vdj_t/temp_${b}-${w}Filtered_Contig.csv 
awk -v w=$w -F"," 'BEGIN {OFS = ","} FNR==1{$(NF+1)="Well_ID"} FNR>1{$(NF+1)=w;} 1' ${d}/vdj_b/filtered_contig_annotations.csv >${d}/vdj_b/temp_${b}-${w}Filtered_Contig.csv 

#add batch id
echo $(stm "Adding Batch ID")

awk -v b=$b -F"," 'BEGIN {OFS = ","} FNR==1{$(NF+1)="Batch_ID"} FNR>1{$(NF+1)=b;} 1'  ${d}/vdj_t/temp_${b}-${w}Filtered_Contig_Reformated.csv >${d}/vdj_t/${b}-${w}_Filtered_Contig_Airr.csv 
awk -v b=$b -F"," 'BEGIN {OFS = ","} FNR==1{$(NF+1)="Batch_ID"} FNR>1{$(NF+1)=b;} 1'  ${d}/vdj_b/temp_${b}-${w}Filtered_Contig_Reformated.csv >${d}/vdj_b/${b}-${w}_Filtered_Contig_Airr.csv

awk -v b=$b -F"," 'BEGIN {OFS = ","} FNR==1{$(NF+1)="Batch_ID"} FNR>1{$(NF+1)=b;} 1'  ${d}/vdj_t/temp_${b}-${w}Filtered_Contig.csv >${d}/vdj_t/${b}-${w}_Filtered_Contig_Reformated.csv 
awk -v b=$b -F"," 'BEGIN {OFS = ","} FNR==1{$(NF+1)="Batch_ID"} FNR>1{$(NF+1)=b;} 1'  ${d}/vdj_b/temp_${b}-${w}Filtered_Contig.csv >${d}/vdj_b/${b}-${w}_Filtered_Contig_Reformated.csv



rm ${d}/vdj_t/temp*
rm ${d}/vdj_b/temp*


gzip -f ${d}/vdj_b/${b}-${w}_Filtered_Contig_Airr.csv
gzip -f ${d}/vdj_t/${b}-${w}_Filtered_Contig_Airr.csv 


echo $(stm "Done");