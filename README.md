# tenx-vdj-pipeline

Scripts for initial processing of 10x Genomics 5 pimrme vdj data(scTCR/scBCR)

<a id="contents"></a>

## Contents

#### [Dependencies](#dependencies)

#### [Cellranger Mulit output formating: multi_output_formatting.sh](#formating)
- [Parameters](#formating_param)
- [Example](#formating_example)
- [Outputs](#formating_outputs)

#### [Splitting Contig files: split_contig_by_hash .sh](#split)
- [Parameters](#split_param)
- [Example](#split_example)
- [Outputs](#split_outputs)



<a id="dependencies"></a>

## Dependencies

This repository requires that `csvtool`
```
sudo apt-get install csvtool
```

`H5weaver` is found in the aifimmunology Github repositories. Install with:
```
Sys.setenv(GITHUB_PAT = "[your_personal_token_here]")
devtools::install_github("aifimmunology/H5weaver")
```

<a id="formating"></a>

## Output Formating for cellranger Mulit output

This script will split metric_summary.scv into three summary files that corresponding to gene expression, scTCR, scBCR library. The gene expression summary file can be used directly into tenx-rnaseq-pipeline/run_add_tenx_rna_metadata.R. It will also add two columns (Well_ID, Batch_ID) to the filtered_contig_annotation files. 


[Return to Contents](#contents)

<a id="formating_param"></a>

There are 3 parameters for this script:  
- `-d `: The path to cellrnager Multi output outs/per_sample_outs/*/   
- `-b `: Batch ID 
- `-w `: Well ID

<a id="formating_example"></a>


An example run for a cellranger count result is:
```
bash mulit_output_fomrating.sh \
     -d EXP-00196-Multi-R1C1W1/outs/per_sample_outs/EXP-00196-Multi-P1C1W1/
     -b EXP-00196
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

## split filtered contig by hash 

This script will split the Filtered_Contig_Reformated.csv files based on cell hashing result. HTO files comes from cell hashing pipeline output.

[Return to Contents](#contents)

<a id="split_param"></a>

There are 4 parameters for this script:  
- `-c `: Input HTO Category
- `-i `: Input Reformated Contig File 
- `-o `: Output Directory
- `-w `: Well ID


<a id="split_example"></a>


An example run for a cellranger count result is:
```
bash split_contig_by_hash.shh \
     -c EXP-00196-P1C1W1_hto_category_table.csv.gz
     -i EXP-00196-MuLti-R1C1W1/outs/per_sample_outs/EXP-00196-MuLti-P1C1W1/vdj_b/EXP-00196-P1C1W1_Filtered_Contig_Reformated.csv
     -w P1C1W1
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


[Return to Contents](#contents)


