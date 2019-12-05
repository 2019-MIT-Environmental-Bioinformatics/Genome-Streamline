# Genome-Streamline
The official repo for Zac, Cory, and Noah

## Background

In this project, we aim to recapitulate key results from the paper by Swan et al. 2013 - "Prevalent genome streamlining and latitudinal divergence of planktonic bacteria in the surface ocean." The authors recovered partial single amplified genomes (SAGs) from 56 bacterial cells from three sites in the surface ocean: the Gulf of Maine, the Mediterranean, and the North Pacific. Their analyses demonstrated that these SAGs display signs of "genome streamlining", such as smaller genomes, fewer gene duplications, and lower GC content, among others. They accomplished this by thoroghly annotating the genomes and performing functional reconstructions. Furthermore, taking avantage of the availability of recently collected surface ocean metagenomes, they investigated the distribution of their SAGs (or those from closely related taxa) and demonstrated the affinity of certain taxa for particular environments. 

While the authors performed a number of analyses, the results of which are presented both in the main text and supplement, we chose to focus our efforts on three main areas: annotation and functional mapping, signals of genome streamlining, and biogeography via fragment recruitment. We chose both based on our respective interests but also because we deemed them to be the most salient findings. Furthermore, several of these findings are depicted in figures which we could attempt to recreate. 

Below we have outlined the general steps we took to achieve each aim. We have included the sames of specific scripts and environments necessary to perform each step in the analysis, as well as expected output and log files where possible. 

## Part 0: General Notes
Noah: Protein annotation and functional biosynthesis mapping

Zac: Metagenome/SAG Comparison

Cory: Paralogs + GC content. Also, downloading the data.

We performed computational tasks using WHOI's Poseidon HPC---all shell scripts contained in the `scripts/` directory call resources specific to the structure of this cluster, and present a fundamental barrier to anyone else repeating our analysis. 

Additionally, while there are scripts for downloading the metagenomic data, rRNA annotation, filtering, etc., these rely on conda environments that can be found in .yaml files in the `/envs` directory. The `envs/` folder also contains a folder labelled `busco/`; this is not a conda environment, but a program that we downloaded and ran manually. The SAG, cultured genome, and metagenome downloading was done manually, and because all raw data for this project takes up substantial storage space, they do not reside in the repo. Scripts to run analyses often point to the `../data` superdirectory outside this one. 

## Part 1: Protein Annotation and Functional Mapping (Noah)

### 1.1 Identifying proteins
Scripts:
```
scripts/
    Prodigal-1.sh
```

For the 56 SAGs analyzed by Swan et al., we used Prodigal to identify protein-coding genes as the authors did, the script for doing so is `scripts/Prodigal-1.sh`. We also used Prodigal to identify protein coding genes for the cultured genomes.

The authors utilized several utilities for mapping functional genes: the NCBI nonredundant database (nr), UniProt, TIGRfam, Pfam, KEGG, COG, and InterPro. We used the BLASTp utility to find functional orthologs in nr, as well as a utility (eggNOG v2.0) for functional mapping that did not exist at the time of publication.

### 1.2 Annotation
Scripts:
```
scripts/
    Blastp.sh
    Blast-custom.sh
    eggNOGger.sh
    eggNOGger_cust.sh
../data/proteins/
```

All the scripts listed here are particular to the Poseidon cluster and SLURM. They use modulefiles pre-loaded on the cluster and a manual download of eggNOG and its requisite databases. Details on the latter can be found here: 

https://github.com/eggnogdb/eggnog-mapper/wiki/eggNOG-mapper-v2

All scripts also use translated protein data from `Prodigal-1.sh`. `Blastp.sh` is the most computationally expensive, taking nearly 24 hours across 16 nodes with 36 cores each. This is likely because I don't fully understand how to use the cluster. 

The `-custom` type scripts are meant to be changed before they are run, because each accounts for a SAG or two that, for some reason, the batch scripts miss. I was never able to figure out why, and did not want to run that BLASTp job more than I had to.

### 1.3 Comparison
Files:
```
scripts/
    split_proteins.sh
    create_taxonmatch.sh
jupyter-notebooks/
    Metabolism_Tables_Compare.ipynb
wrangling/
    taxon_match.tsv
    enzyme_nos.csv
../data/eggNOGged/
```

You won't need `create_taxonmatch.sh`; it automated part of the creation of `wrangling/taxon_match.tsv`, and the rest was manual. This was required because the paper does not provide the SAG-taxon-location table in a parseable digital format. 

*You will notice that in my final comparison that I only used the eggNOG results. It's less computationally taxing, and it produces results that I can figure out how to link to enzymes. I still haven't figured that out for BLASTp.*

`split_proteins.sh` takes the eggNOG output (in the `data/` dir *not* pushed to GitHub) and splits each output file into a reasonable .tsv for later reading (though this was unnecessary due to the `pandas.read_csv(...,skiprows=)` flag), as well as its respective header and footer. 

In the case that you *just* want to be walked through the final analysis, it is all in the `final_comparison.ipynb` file, but the creation of the last figure happens in `Metabolism_Tables_Compare.ipynb`. The former file just calls the figure created by the latter to be lightweight. In this final comparison, `enzyme_nos.csv` (which is effectively a manually-copied Table S9 from Swan et al.) is loaded as a reference, and the cut files from `split_proteins.sh` are loaded, one at a time. Each time one file is loaded, a new column is added to a Pandas DataFrame object based on `enzyme_nos.csv`, where the presence or absence of certain enzyme reaction numbers (*EC*s) is noted by a boolean 1/0. This table is organized in an identical way to `enzyme_nos.csv` and while we have chosen two ways (summing the enzyme hits and a heatmap of agreement/disagreement) to compare the data, they are there for any intrepid soul to look at. 

## Part 2: Signals of Genome Streamlining (Cory)

### 2.1 GC Content
Scripts: 
```
scripts/
    get_GC.sh
    GC_plot.R
```

The `get_GC.sh` bash script calculates GC content by dividing the grepped count of G+C nucleotides divided by the count of all ATGC nucleotides. The script does this count for five groups of input files: genomic SAG's, SAG coding regions (CDS), genomic cultures, culture coding regions, and the filtered metagenomes (see Part 3.3). The GC contents are printed in five corresponding files in the /output/genome_stats folder. 

The R script `GC_plot.R` then plots these GC contents as five boxplots. `GC_plot.R` also performs t-tests between these lists to check for significant differences in GC content between groups.


### 2.2 Genome Size estimation and paralogs
Scripts:
```
scripts/
    get_genome_size.sh
    busco_script.sh
    parse_busco.sh
    BlastClust.sh
    get_paralogs.sh
    para_plot.R
logs/
    Blastclust_491617.log
    Blastclust_491760.log  
    Blastclust_491807.log     
    busco_493909.log
    busco_493941.log
output/
    blastclust/
    busco/
    genome_stats/
```

The bash script `get_genome_size.sh` simply counts the number of nucleotides in all SAG and cultured genome fasta files.

Genome assembly completeness was assessed using the Benchmarking set of Unviersal Single-Copy Orthologs (BUSCO). The BUSCO databases for bacteria, actinobacteria, bacteroidetes, proteobacteria, and gammaproteobacteria were downloaded and stored in our (unpushed) data folder, although only the bacteria database is needed to reproduce my figures. BUSCO was downloaded and installed in the `envs/` folder, although it's not a conda environment. In order to set up the program, I modified BUSCO's config.ini file with the paths to the HPC modules of tblastn, hmmer, and ausgustus. 

The `busco_script.sh` bash script first performs BUSCO analysis on all SAG genomes against the bacteria BUSCO database in nucleotide mode. Then, if a SAG belongs to a group for which a more specific database is available (ie. actinobacteria), it performs the analysis for that SAG using that database. Then it repeats this for the predicted proteins using BUSCO in protein mode. The bash script `parse_busco.sh` parses the BUSCO output and prints the ID, database, and percent of complete orthologs of each SAG and cultured genome. I examined all of this data, but the final figures only include the results from the BUSCO bacteria database in protein mode.

Following the procedures of Swan et al., the script `BlastClust.sh` writes clusters of 'paralogs' based on sequence similarity (in `output/blastclust/`). It does this for SAG's and cultures. The bash script `get_paralogs.sh` then reports the number of proteins that are in a cluster with at least one other protein, divided by the total number of predicted proteins.

Finally, the R script `para_plot.R`uses the BUSCO results and SAG assembly sizes to estimate the size of the organism's genome. It plots these estimated genome sizes (as well as the actual cultured genome sizes) against the estimated number of 'paralogs' for each genome (see Jupyter notebook for details). The R scrupt also uses an ANOVA test to test whether the regression lines for SAG's and cultures have different slopes (they do). 

## Part 3: Metagenome Fragment Recruitment (Zac)

Swan et al. 2013 investigated the geographic distributions of their SAGs by using previously generated metagenomic datasets from the surface ocean. Their results are presented in Figure 3. To generate this data, they BLASTed the metagenomic reads against their SAGs to describe how well represented sequences from each SAG are in each metagenome. The metagenomes originated mostly from the Global Ocean Sampling expeditions, though there were a smattering of other projects as well. They used 41 SAGs and 89 metagenomes in all, for a total of 3649 comparisons. Prior to fragment recruitment using BLAST, the authors performed a series of processing and filtering steps. We attempted to recreate their analyses, in some cases using different tools or approaches. The pipeline we used is described in the following sections.

### Part 3.1: Metagenome Retrieval
    code:
        wrangling/metagenome_fetching_filtering.ipynb
        scripts/SRA_download.sh
        scripts/HF10_download.sh
        scripts/get_GOS.sh
    envs:
        envs/downloading.yaml
    logs:
        logs/get_GOS_480700.log
        logs/HF10_download_480800.log
        logs/SRA_download_481018.log
    output:
        ../data/metagenomes/{metagenome_ID}/*.fastq.gz *.fa.gz

Table S5 contains the metadata for the metagenomes they used for fragment recruitment. However, no accession numbers are provided. Furthermore, despite there being 89 metagenomes (columns in Figure 3), there were over 100 entries in Table S5, indicating that some stations had multiple associated accessions. Many of the stations from which metagenomes were recovered were sampled at multiple depths and size fractions. The specific accessions that were used were not specified in the paper. We inferred that all samples should be from the shallowest depth (surface) and from the prokaryotic size fraction (~0.1 um). However, this information was often missing from the SRA metadata. When possible, this was inferred from sample naming conventions, though it is likely that the metagenomic data we retrived is quite divergent from that used in the paper.  

Most of the metagenomic data munging process is documented in a Jupyter notebook in the 'wrangling' folder within this repo. The data is retrieved using the three SLURM scripts listed at the top of this subsection. Some manual processing in bash was performed on the GS000 and GS001 samples to get them into the appropriate format. 

This process results in a single folder per station, each containing one or more zipped fasta or fastq files. They are located in the ../data/metagenomes folder on Poseidon contained outside this GitHub repo. 

### Part 3.2: Predict and Annotate SAG rRNA Genes
    code:
        scripts/rRNA_pred.sh
    envs:
        envs/rRNA_prediction.yaml
    logs:
        logs/barrnap_484697.log
    output:
        ../data/rRNAs/*.fna *.gff

The 16S, 23S, 5.8S, and internal transcribed spacer regions were masked during fragment recruitment in the original analysis. To replicate this processing step, we used the tool 'barrnap'. This predicts ribosomal sequences using models rRNA genes. This process is executed by the 'rRNA_pred.sh' SLURM script. 

This process results in two files per SAG, one .fna file containing the sequences and one .gff file with the genome coordinates. They are located in the ../data/rRNAs folder on Poseidon contained outside this GitHub repo.

### Part 3.3: Metagenome Filtering and Processing
    code:
        scripts/prinseq_n_cat.sh
    envs:
        envs/prinseq.yaml
    logs:
        logs/prinseq_n_cat_489992.log
    output"
        ../data/metagenomes_filtered/*.fa.gz

Because many stations had multiple associated accessions, the metagenome data retrieval process yielded multiple files per station. These needed to be filtered using PRINSEQ, as done in the paper, and concatenated into a single file per metagenome for efficiency in the fragment recruitment step. This is peformed using the 'prinseq_n_cat.sh' SLURM script. 

This process results in one zipped fasta file per metagenome containing all of the reads. They are located in the ../data/metagenomes_filtered folder on Poseidon contained outside this GitHub repo.

### Part 3.4: Fragment Recruitment
    code:
        scripts/frag_recruit_step1.sh
        scripts/frag_recruit_step2.sh
    envs:
        envs/bbtools.yaml
        envs/seqkit.yaml
        envs/blast_2.2.31.yaml
    logs:
        logs/frag_recruit_step1_490841.log
        logs/frag_recruit_step2_490883-10.log
        logs/frag_recruit_step2_490883-11.log
        logs/frag_recruit_step2_490883-12.log
        logs/frag_recruit_step2_490883-13.log
        logs/frag_recruit_step2_490883-14.log
        logs/frag_recruit_step2_490883-15.log
        logs/frag_recruit_step2_490883-16.log
        logs/frag_recruit_step2_490883-17.log
        logs/frag_recruit_step2_490883-18.log
        logs/frag_recruit_step2_490883-19.log
        logs/frag_recruit_step2_490883-1.log
        logs/frag_recruit_step2_490883-20.log
        logs/frag_recruit_step2_490883-21.log
        logs/frag_recruit_step2_490883-22.log
        logs/frag_recruit_step2_490883-23.log
        logs/frag_recruit_step2_490883-24.log
        logs/frag_recruit_step2_490883-25.log
        logs/frag_recruit_step2_490883-26.log
        logs/frag_recruit_step2_490883-27.log
        logs/frag_recruit_step2_490883-28.log
        logs/frag_recruit_step2_490883-29.log
        logs/frag_recruit_step2_490883-2.log
        logs/frag_recruit_step2_490883-30.log
        logs/frag_recruit_step2_490883-31.log
        logs/frag_recruit_step2_490883-32.log
        logs/frag_recruit_step2_490883-33.log
        logs/frag_recruit_step2_490883-34.log
        logs/frag_recruit_step2_490883-35.log
        logs/frag_recruit_step2_490883-36.log
        logs/frag_recruit_step2_490883-37.log
        logs/frag_recruit_step2_490883-38.log
        logs/frag_recruit_step2_490883-39.log
        logs/frag_recruit_step2_490883-3.log
        logs/frag_recruit_step2_490883-40.log
        logs/frag_recruit_step2_490883-41.log
        logs/frag_recruit_step2_490883-4.log
        logs/frag_recruit_step2_490883-5.log
        logs/frag_recruit_step2_490883-6.log
        logs/frag_recruit_step2_490883-7.log
        logs/frag_recruit_step2_490883-8.log
        logs/frag_recruit_step2_490883-9.log
    output:
        ../data/frag_recruit/SAG_stats_postfilter.txt
        ../data/frag_recruit/SAG_stats_prefilter.txt
        ../data/frag_recruit/{metagenome_ID}.{SAG_ID}.tsv


This process consists of multiple steps, split over two SLURM scripts. 'frag_recruit_step1.sh' takes the rDNA sequences generated from barrnap, aligns them to the SAGs, and then turns the aligned sequence to lowercase. This is performed using BBTools. After converting to lowercase, seqkit is used to get statistics on SAG length and filtering the SAGs by remove contigs less than 2000 bp. 

'frag_recruit_step2.sh' is a SLURM array script that peforms all processes associated with BLAST, first making the masked databases from the SAGs, and then BLASTing each filtered metagenome against each filtered SAG. This results in 3649 tsv files that contain the BLAST results in tabular format. They are named using the convention metagenome_ID.SAG_ID.tsv (i.e. GS394.AAA300-J16.tsv) and are found in the ../data/frag_recruit/ folder on Poseidon outside this GitHub repo. It also generates statistics on the SAGs before and after removal of contigs less than 2000 bp (SAG_stats_postfilter.txt and SAG_stats_prefilter.txt).

### Part 3.5: Results Processing and Visualization
    code:
        jupyter_notebooks/parse_frag_blast.ipynb
    output:
        output/plots/recreated_fig3.png
        
This step parses the BLAST output generated in the step above and calculates the percent represenation of each SAG in each metagenome, normalizing for SAG length, and then generates a heatmap that emulates Figure 3 from the paper. This process is carried out in the parse_frag_blats.ipynb Jupyter notebook. The sole output is the heatmap 'recreated_fig3.png'.
