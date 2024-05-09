![[logo-bi-18-7| width=10px]](https://user-images.githubusercontent.com/90496643/169656572-a93ad3c6-2e70-481a-b749-470e02f84e7e.svg#gh-dark-mode-only)
![logo-bi-18-3](https://user-images.githubusercontent.com/90496643/169656574-08b10a55-abe4-401b-bdd2-c9518c4c4f38.svg#gh-light-mode-only)

</br>

# The shadow of HIV: searching for indirect signs of HIV infection in cell-free DNA samples

**Authors**  
- Ilia Popov
- Daria Nekrasova
- Dorzhi Badmadashiev


**Supervisors**
- Alisa Morshneva
- Polina Kozyulina

**THIS REPO IS CURRENTLY AT WORK**

## Table of contents

- [Introduction](#introduction)
- [Pipeline](#pipeline)
  - [Unmapped reads extraction](#unmapped-reads-extraction)
    - [IonTorrent samples](#iontorrent-samples)
    - [BGI samples](#bgi-samples)
  - [Assigning taxonomic labels](#assigning-taxonomic-labels)
  - [Creating residual virus and microbiome profiles of two datasets](#creating-residual-virus-and-microbiome-profiles-of-two-datasets)
  - [Finding the differences in exogenous DNA composition between HIV- and HIV+ NIPT samples](#finding-the-differences-in-exogenous-dna-composition-between-hiv--and-hiv-nipt-samples)
- [Results](#results)
  - [Differential abundance](#differential-abundance)
  - [Relative abundance](#relative-abundance)
  - [α-diversity](#α-diversity)
  - [β-diversity](#β-diversity)
  - [Overall](#overall)

## Introduction

[Написать сколько образцов было (IonTorrent и BGI / ВИЧ+ и ВИЧ-). Написать, какие ограничения исследования имеются - диагностика ВИЧ инфекции с помощью опросников. Написать, что часть работы была выполнена на сервере. Аналитическая часть работы описана в лабораторном журнале. Написать про разные среды для conda.]

## Pipeline

### Unmapped reads extraction

#### IonTorrent samples

IonTorrent samples were already in `.bam` format. Unmapped reads were extracted using `samtools v.X.X.`<br>
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
- [`run_kreport2mpa.sh`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/run_kreport2mpa.sh) - to use KrakenTools for ~800 files at once
- [`find_line.py`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/find_line.py) - to find contaminants precisely
- [`delete_lines.py`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/delete_lines.py) - to delete them
- [`processing_script.py`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/processing_script.py) - to return sample_ids to files
- [`convert2csv.py`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/convert2csv.py) - to convert `.txt` files to `.csv` files
- [`filter_possible_contaminants.py`](https://github.com/iliapopov17/The-shadow-of-HIV/blob/main/scripts/filter_possible_contaminants.py) - to filter contaminants based on the data criteria

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

To find the association between clinical metadata and microbial meta-omics features `MaAslin2 v.X.X.` was used

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

## Results

### Differential abundance

### Relative abundance

### α-diversity

### β-diversity

### Overall
