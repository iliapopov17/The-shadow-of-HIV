![[logo-bi-18-7| width=10px]](https://user-images.githubusercontent.com/90496643/169656572-a93ad3c6-2e70-481a-b749-470e02f84e7e.svg#gh-dark-mode-only)
![logo-bi-18-3](https://user-images.githubusercontent.com/90496643/169656574-08b10a55-abe4-401b-bdd2-c9518c4c4f38.svg#gh-light-mode-only)

</br>

# The shadow of HIV: searching for indirect signs of HIV infection in cell-free DNA samples

**Authors**  
- Ilia Popov, MD <a href="https://orcid.org/0000-0001-7947-1654"><img alt="ORCID logo" src="https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png" width="16" height="16" /></a>
- Daria Nekrasova <a href="https://orcid.org/0000-0002-0028-9727"><img alt="ORCID logo" src="https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png" width="16" height="16" /></a>
- Dorzhi Badmadashiev <a href="https://orcid.org/0000-0002-3406-6353"><img alt="ORCID logo" src="https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png" width="16" height="16" /></a>


**Supervisors**
- Alisa Morshneva <a href="https://orcid.org/0000-0002-8545-6052"><img alt="ORCID logo" src="https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png" width="16" height="16" /></a>
- Polina Kozyulina <a href="https://orcid.org/0000-0001-8520-3445"><img alt="ORCID logo" src="https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png" width="16" height="16" /></a>

## Table of contents

- [Introduction](#introduction)
- [Pipeline](#pipeline)
  - [Overview](#overview) 
  - [Unmapped reads extraction](#unmapped-reads-extraction)
    - [IonTorrent samples](#iontorrent-samples)
    - [BGI samples](#bgi-samples)
  - [Assigning taxonomic labels](#assigning-taxonomic-labels)
  - [Creating residual virus and microbiome profiles of two datasets](#creating-residual-virus-and-microbiome-profiles-of-two-datasets)
  - [Finding the differences in exogenous DNA composition between HIV- and HIV+ NIPT samples](#finding-the-differences-in-exogenous-dna-composition-between-hiv--and-hiv-nipt-samples)
    - [Differential abundance](#differential-abundance)
    - [Relative abundance](#relative-abundance)
    - [Biodiversity](#biodiversity)
    - [Core microbiota](#core-microbiota)
- [Results](#results)
  - [Overview](#overview-1)
  - [Counts distribution](#counts-distribution)
  - [Differential abundance](#differential-abundance-1)
  - [Relative abundance](#relative-abundance-1)
  - [α-diversity](#α-diversity)
  - [β-diversity](#β-diversity)
  - [Core microbiota](#core-microbiota-1)
- [Summary](#summary)
- [References](#references)

## Introduction

[Написать сколько образцов было (IonTorrent и BGI / ВИЧ+ и ВИЧ-). Написать про экзотику данных. Написать, что часть работы была выполнена на сервере. Аналитическая часть работы описана в лабораторном журнале. Написать про среду для conda.]

## Pipeline

### Overview

![pipeline](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/pipeline.png#gh-light-mode-only)
![pipeline](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/pipeline-dark.png#gh-dark-mode-only)

_Figure 1. The whole pipeline overview._

### Unmapped reads extraction

#### IonTorrent samples

IonTorrent samples were already mapped to the human genome and files were presented in `.bam` format. Unmapped reads were extracted using `samtools v.X.X.`<br>
See [`Snakefiles/Snakefile_IonTorrent`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/Snakefiles/Snakefile_IonTorrent) file for details.

#### BGI samples

BGI samples were mapped to the Human Reference Genome (version X) using `bowtie2 v.X.X.` Then unmapped reads were also extracted usint `samtools v.X.X.`<br>
See [`Snakefiles/Snakefile_BGI`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/Snakefiles/Snakefile_BGI) file for details.

### Assigning taxonomic labels

Taxonomic identification was performed with `kraken2 v.X.X.` utilizing full PlusPF (77GB) database with 0.6 confidence threshold.

<details><summary>
<b>Clipped image from Snakefiles with kraken2 parameters:</b>
</summary><br> 

```
rule kraken:
    input:
        fastq="fastq_BGI/{sample}_unmapped.fastq",
        db="/path/to/kraken2_db" #enter path to db
    output:
        report = "kraken_report_BGI/{sample}_kraken_report.txt",
        out = "kraken_output_BGI/{sample}_kraken_output.txt"
    shell:
        """
        kraken2 --db {input.db} --output {output.out} \
        --report {output.report} --confidence 0.60 {input.fastq}
        """
```
  
</details>

### Creating residual virus and microbiome profiles of two datasets

#### Metdata

All samples (both IonTorrent and BGI)  names were organised with this pattern: "YYYYMMDD_ID" and organized to different directories (e.g. `HIV` & `CTRL`). <br>
`metadata.csv` was generated using [`scripts/create_metadata.py`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/create_metadata.py) script.

<details><summary>
<b>Clipped image from laboratory journal:</b>
</summary><br> 

```python
# Usage
# {path_to_script} {path_to_HIV_samples} {path_to_ctrl_samples} {output_file_name}
%run scripts/create_metadata.py HIV/ CTRL/ metadata.csv
```
</details>

#### Counts

6 `counts.csv` files (from _species_ to _phylum_ level) were parsed from kraken2 reports using `KrakenTools v.X.X.` <br>
Possible contamination filtering was performed on this step. <br>

Self-written scripts utilizied:

|Script|Purpose|
|------|-------|
|[`run_kreport2mpa.sh`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/run_kreport2mpa.sh)|to use KrakenTools for ~800 files at once|
|[`find_line.py`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/find_line.py)|to find contaminants precisely|
|[`delete_lines.py`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/delete_lines.py)|to delete them|
|[`processing_script.py`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/processing_script.py)|to return sample_ids to files|
|[`convert2csv.py`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/convert2csv.py)|to convert `.txt` files to `.csv` files|
|[`filter_possible_contaminants.py`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/filter_possible_contaminants.py)|to filter contaminants based on the data criteria|

_Table 1. Scripts used to parse `counts.csv` files_

<details><summary>
<b>Contamination filtering criterias</b>
</summary><br> 
The criteria about identifying and removing potential contamination in our data is based on the collection dates of the samples.

When analyzing cell-free DNA from various samples, ideally, the organisms (taxa) detected should be distributed somewhat randomly across different samples, depending on their source, environment, etc. If certain organisms appear only in samples that were collected on the same date, this pattern might suggest that those organisms weren't actually present in the samples originally but were introduced accidentally on that particular day—possibly during sample collection, processing, or handling.

**Key Points**:

- **Same Date, Same Taxon**: If we find that a specific organism (taxon) appears exclusively in samples that were all collected on the same date, and this organism does not appear in samples from other dates, it might indicate contamination.
- **Cross-Verification**: Check if this organism appears in other samples that are not from that specific date. If it doesn’t, this supports the contamination theory.
- **Removal of Suspected Data**: To ensure the integrity of data analysis, these suspected contaminated data points should be removed before performing further analysis.

Due to limitation this filtration will be performed only on _species_ level. Because we can filter out _Klebsiella variicola_ that was found only on 2022/03/03, but we cannot remove the whole _Klebsiella_ genus.

In addition, the following taxa were weeded out of the data:
- _Cutibacterium acne_
- All bacteriophages
</details>

### Finding the differences in exogenous DNA composition between HIV- and HIV+ NIPT samples

#### Differential abundance

To find the association between clinical metadata and microbial meta-omics features `MaAslin2 v.X.X.` was used.<br>
See [`scripts/MaAsLin2.R`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/MaAsLin2.R) script for details.

<details><summary>
<b>MaAsLin2 launch parameters:</b>
</summary><br> 

```r
fit_data = Maaslin2(input_data     = counts, 
                    input_metadata = metadata, 
                    min_prevalence = 0,
                    normalization  = "TSS",
                    output         = "MaAsLin2_results",
                    analysis_method = "LM",
                    max_significance = 0.2,
                    correction = "BH",
                    plot_heatmap = TRUE,
                    plot_scatter = TRUE,
                    fixed_effects  = c("HIV_status"))
```
</details>

MaAsLin2 results were visualized as volcano plot with [`Volcano_plot/volcano.R`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/Volcano_plot/volcano.R) script.<br>

Reasons for volcano plot instead of heatmap:

1. Volcano plot allowed 2 metrics to be plotted at once: `log2fc` & `p-value`.
2. We only have 2 groups: HIV+ and HIV-. Heatmap is useful when more groups are displayed. Volcano plot is perfect for 2 groups.
3. Volcano plot is the classic way of displaying differential relative data.
4. Aesthetic principles: MaAsLin2 found ~100 statistically significant taxa, the heatmap would be too high/wide (depending on configuration).

#### Relative abundance

Mean relative abundance barplots were visualised to determine the relative percentage of a particular taxon in samples from the HIV+ and HIV- groups
Visualization was made with [`scripts/Bar_plot.R`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/Bar_plot.R) script. <br>

<details><summary>
<b>Clipped image from laboratory journal:</b>
</summary><br> 

```python
# Usage
# {path_to_script} {path_to_metadata} {path_to_counts_species} {path_to_counts_genus} {path_to_counts_family} {path_to_counts_order} {path_to_counts_class} {path_to_counts_phylum}
! Rscript scripts/Bar_plot.R metadata.csv counts/counts_species_filtered.csv counts/counts_genus.csv counts/counts_family.csv counts/counts_class.csv counts/counts_order.csv counts/counts_phylum.csv
```
</details>

#### Biodiversity

**α-diversity**

To measure mean species diversity in HIV+ and HIV- groups 3 α-diversity indices were estimated:
- Shannon index
- Chao1 index
- Pileou index<br>

To compare the values of each index between HIV+ and HIV- groups Mann-Whitney U Test was used.<br>
See [`scripts/Alpha_div_calculations.R`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/Alpha_div_calculations.R) & [`scripts/Alpha.R`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/Alpha.R) scripts for details.

**β-diversity**

To measure the extent of differentiation (distribution) of species according to HIV status β-diversity in 2 metrics:
1. Bray-Curtis similarity
2. Jaccard dissimilarity<br>

To compare the values of each metric between HIV+ and HIV- groups PERMANOVA was used.<br>
See [`Beta_div/beta_diversity.R`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/Beta_div/beta_diversity.R) script for details.

<details><summary>
<b>Rarefaction criterias:</b>
</summary><br> 

**Bray-Curtis similarity**
```r
bray <- avgdist(taxon_counts, dmethod="bray", sample=10)%>%
  as.matrix()%>%
  as_tibble(rownames = "sample_id")
```

**Jaccard dissimilarity**
```r
jaccard <- avgdist(taxon_counts, dmethod="jaccard", sample=10)%>%
  as.matrix()%>%
  as_tibble(rownames = "sample_id")
```
</details>

#### Core microbiota

The script [`scripts/core_microbiota_HIV.py`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/core_microbiome_HIV.py) was used to draw the core microbiota graphs.

## Results

### Overview

![main-results](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/main-results.png#gh-light-mode-only)
![main-results](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/main-results-dark.png#gh-dark-mode-only)

_Figure 2. Main results overview._

### Counts distribution

Counts distribution graphs were made with [`scripts/describe.py`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/describe.py) script

<details><summary>
<b>Clipped image from laboratory journal:</b>
</summary><br> 
  
```
# Usage
# {path_to_script} {path_to_input_file} {taxonomic_level}
%run scripts/describe.py "counts/counts_species_filtered.csv" Species
```
</details>

|Species|Genus|Family|Order|Class|Family|
|-------|-----|------|-----|-----|------|
|<img src="https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/counts_distribution/distr_species.png"/>|<img src="https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/counts_distribution/distr_genus.png"/>|<img src="https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/counts_distribution/distr_family.png"/>|<img src="https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/counts_distribution/distr_order.png"/>|<img src="https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/counts_distribution/distr_class.png"/>|<img src="https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/counts_distribution/distr_phylum.png"/>|

_Table 2. Counts distribution on every taxonomic level_

It is clearly can be seen that the the distribution graph is shifted to the right in all cases.

### Differential abundance

![diff-abund](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/diff-abund.png#gh-light-mode-only)
![diff-abund](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/diff-abund-dark.png#gh-dark-mode-only)

_Figure 3. Volcano plot with differential bacterial abundance._

### Relative abundance

![rel-abund](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/rel-abund.png#gh-light-mode-only)
![rel-abund](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/rel-abund-dark.png#gh-dark-mode-only)

_Figure 4. Mean Relative Abundance from species to phylum level._

### α-diversity

|Index|HIV-|HIV+|_p_-value|
|-----|----|----|--------|
|Shannon|N|N|N|
|Chao1|N|N|N|
|Pileou|N|N|N|

_Table 3. α-diversity metrics_

![alpha-div](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/alpha-div.png#gh-light-mode-only)
![alpha-div](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/alpha-div-dark.png#gh-dark-mode-only)

_Figure 5. α-diversity visualization._

### β-diversity

|Index|PERMANOVA _p_-value|
|-----|----|
|Bray-Curtis similarity|<0.001|
|Jaccard dissmilarity|<0.001|

_Table 4. β-diversity comparison between HIV+ and HIV- groups_

![beta-div](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/beta-div.png#gh-light-mode-only)
![beta-div](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/beta-div-dark.png#gh-dark-mode-only)

_Figure 6. β-diversity visualization._

### Core microbiota

|HIV+|HIV-
|-------|-----|
|<img src="https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/core_microbiota/hiv%2B-standart.png"/>|<img src="https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/imgs/core_microbiota/hiv--standart.png"/>|

_Table 4. Core microbiota for HIV+ and HIV- groups_

## Summary

## References
