# tenx-vdj-pipeline

Scripts for initial processing of 10x Genomics 5 prime vdj data (scTCR/scBCR)

<a id="contents"></a>

## Contents

#### [WorkFlow](#pipeline_flow)

#### [Dependencies](#dependencies)

#### [CellHashing SampleSheet](#SampleSheet)


#### [Cellranger Mulit Output Formating: multi_output_formatting.sh](#formating)
- [Parameters](#formating_param)
- [Example](#formating_example)
- [Outputs](#formating_outputs)

#### [Split Contig Files: split_contig_by_hash.sh](#split)
- [Parameters](#split_param)
- [Example](#split_example)
- [Outputs](#split_outputs)

#### [Merge Contig Files: merge_contig_by_hash.sh](#merge)
- [Parameters](#merge_param)
- [Example](#merge_example)
- [Outputs](#merge_outputs)

#### [Add Contig to H5 Metadata: add_contig_to_h5_metadata.R](#add_contig)
- [Parameters](#add_contig_param)
- [Example](#add_contig_example)
- [Outputs](#add_contig_outputs)

## Pipeline Work Flow 




<a id="dependencies"></a>

## Dependencies

This repository requires that `csvtool` to be installed: 
```
sudo apt-get install csvtool
```

`H5weaver` is found in the aifimmunology Github repositories. Install with:
```
Sys.setenv(GITHUB_PAT = "[your_personal_token_here]")
devtools::install_github("aifimmunology/H5weaver")
```

<a id="SampleSheet"></a>

## CellHashing SampleSheet

Cell hashing sample sheet used in merging step contain 4 columns: SampleID, BatchID, HashTag, PoolID

Example:
```
SampleID,BatchID,HashTag,PoolID
PB02270-02,EXP-00196,HT1,P1
PB02243-02,EXP-00196,HT2,P1
PB01459-02,EXP-00196,HT3,P1
PB01458-02,EXP-00196,HT4,P1
PB01455-02,EXP-00196,HT5,P1
PB01454-02,EXP-00196,HT6,P1
PB01450-02,EXP-00196,HT7,P1
PB01446-02,EXP-00196,HT8,P1
IMM19_692,EXP-00196,HT9,P1
```

<a id="formating"></a>

## Output Formating for Cellranger Mulit 0utput

This script will split metric_summary.scv into three summary files that corresponding to gene expression, scTCR, scBCR library. The gene expression summary file can be used directly into tenx-rnaseq-pipeline/run_add_tenx_rna_metadata.R. It will also add two columns (Well_ID, Batch_ID) to the filtered_contig_annotation files. 


[Return to Contents](#contents)

<a id="formating_param"></a>

There are 3 parameters for this script:  
- `-d `: The path to cellrnager Multi output outs/per_sample_outs/*/   
- `-b `: Batch ID 
- `-w `: Well ID

<a id="formating_example"></a>


An example run for a cellranger multi result is:
```
bash mulit_output_fomrating.sh \
     -d EXP-00196-Multi-R1C1W1/outs/per_sample_outs/EXP-00196-Multi-P1C1W1/ \
     -b EXP-00196 \
     -w P1C1W1
```
<a id="formating_outputs"></a>


Output examples: 

It should add three sumary files under EXP-00196-Multi-R1C1W1/outs/per_sample_outs/EXP-00196-Multi-P1C1W1

- EXP-00196-Multi-P1C1W1/outs/per_sample_outs/EXP-00196-Multi-P1C1W1/EXP-00196-P1C1W1_VDJ_T_summary.csv
- EXP-00196-Multi-P1C1W1/outs/per_sample_outs/EXP-00196-Multi-P1C1W1/EXP-00196-P1C1W1_VDJ_B_summary.csv
- EXP-00196-Multi-P1C1W1/outs/per_sample_outs/EXP-00196-Multi-P1C1W1/EXP-00196-P1C1W1_Gene_Expression_summary.csv

It will also add reformated contig csv files in both EXP-00196-Multi-P1C1W1/outs/per_sample_outs/EXP-00196-Multi-P1C1W1/vdj_b and EXP-00196-Multi-P1C1W1/outs/per_sample_outs/EXP-00196-Mutli-P1C1W1/vdj_t folder

- EXP-00196-Multi-P1C1W1/outs/per_sample_outs/EXP-00196-Multi-P1C1W1/vdj_b/EXP-00196-P1C1W1_Filtered_Contig_Reformated.csv

- EXP-00196-Multi-P1C1W1/outs/per_sample_outs/EXP-00196-Multi-P1C1W1/vdj_t/EXP-00196-P1C1W1_Filtered_Contig_Reformated.csv


<a id="split"></a>

## Split Filtered Contig by Hash 

This script will split the Filtered_Contig_Reformated.csv files based on cell hashing result. HTO files comes from cell hashing pipeline output. Notes: You need to do splitting separately for scTCR and scBCR.

[Return to Contents](#contents)

<a id="split_param"></a>

There are 4 parameters for this script:  
- `-c `: Input HTO Category
- `-i `: Input Reformated Contig File 
- `-o `: Output Directory
- `-w `: Well ID


<a id="split_example"></a>


An example run for a split contig step
```
bash split_contig_by_hash.sh \
     -c EXP-00196-P1C1W1_hto_category_table.csv.gz \
     -i EXP-00196-MuLti-R1C1W1/outs/per_sample_outs/EXP-00196-MuLti-P1C1W1/vdj_b/EXP-00196-P1C1W1_Filtered_Contig_Reformated.csv \
     -w P1C1W1 \
     -o split_contig_scbcr
```


<a id="split_outputs"></a>

The output should be the splitted contig files by hash for each well. The file name start with sample name followed by well name.

Output examples: 

- IMM19_692_P1C1W1_filtered_contig.csv
- PB01446-02_P1C1W1_filtered_contig.csv
- PB01450-02_P1C1W1_filtered_contig.csv
- PB01454-02_P1C1W1_filtered_contig.csv
- PB01455-02_P1C1W1_filtered_contig.csv
- PB01458-02_P1C1W1_filtered_contig.csv
- PB01459-02_P1C1W1_filtered_contig.csv
- PB02243-02_P1C1W1_filtered_contig.csv
- PB02270-02_P1C1W1_filtered_contig.csv
- multiplet_P1C1W1_filtered_contig.csv

## Merge Contig by Hash 

This script will merge contig in the folder of splited contig result. It will detect files with same sample name, and combined them together. Notes: You need to do merging separately for scTCR and scBCR.

[Return to Contents](#contents)

<a id="merge_param"></a>


There are 3 parameters for this script:  
- `-i `: Input Directory from Splitting Step
- `-k `: Input Cell Hashing Sheet 
- `-o `: Output Directory

<a id="merge_example"></a>


An example run for merge contig step
```
bash merge_contig_by_hash.sh \
     -i split_contig_scbcr \
     -k exp-0196-cellhashing_sheet.csv \
     -o merged_contig_scbcr
```

<a id="merge_outputs"></a>


Output examples: 
- EXP-00196-P1_IMM19_692_filtered_contig.csv
- EXP-00196-P1_PB01446-02_filtered_contig.csv
- EXP-00196-P1_PB01450-02_filtered_contig.csv
- EXP-00196-P1_PB01454-02_filtered_contig.csv
- EXP-00196-P1_PB01455-02_filtered_contig.csv
- EXP-00196-P1_PB01458-02_filtered_contig.csv
- EXP-00196-P1_PB01459-02_filtered_contig.csv
- EXP-00196-P1_PB02243-02_filtered_contig.csv
- EXP-00196-P1_PB02270-02_filtered_contig.csv
- EXP-00196-P1_multiplet_filtered_contig.csv


## Add Contig to H5 Metadata 

This script will add contig data into the h5 meta data. scBCR and scTCR need to be added subsequently. 

[Return to Contents](#contents)

<a id="add_contig_param"></a>


There are 6 parameters for this script:  
- `-i `: Input sample h5 files 
- `-c `: Input sample filtered contig files 
- `-d `: Output Directory
- `-b `: Batch ID
- `-t `: In category: "scTCR" or "scBCR"
- `-o `: Output HTML run summary file



<a id="add_contig_example"></a>


An example run for add contig to meta data 
```
Rscript --vanilla tenx-vdj-pipeline/add_contig_to_h5_metadata.R \
     -i /home/jupyter/cell_hash/merged_h5/PB01446-02.h5 \
     -c /home/jupyter/merged_contig_bcr/EXP-00196-P1_PB01446-02_filtered_contig.csv \
     -d /home/jupyter/Add_contig_outputs/ \
     -b EXP-00196 \
     -t scBCR \
     -o EXP-00196-P1_PB01446-02_scBCR_run_summary.html
```

<a id="add_contig_outputs"></a>


Output examples: 
- PB01446-02.h5
- EXP-00196-P1_PB01446-02_scBCR_run_summary.html
- PB01450-02_filtered_contig_scBCR.csv






[Return to Contents](#contents)


