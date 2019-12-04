# Genome-Streamline
The Official (?) repo for Zac, Cory, and Noah

## Part 0: General Notes
Noah: Protein annotation and functional biosynthesis mapping

Zac: Metagenome/SAG Comparison

Cory: Paralogs. Also, downloading the data.

We performed computational tasks using WHOI's Poseidon HPC---all shell scripts contained in the `scripts/` directory call resources specific to the structure of this cluster, and present a fundamental barrier to anyone else repeating our analysis. 

Additionally, while there are scripts (`scripts/SRA_download.sh` and `scripts/HF10_download`) for downloading the metagenomic data, these rely on a conda environment ("downloading") that resides in the `/envs` directory. The SAG downloading was done manually, and because all raw data for this project takes up substantial storage space, it does not reside in the repo. Scripts to run analyses often point to the `../data` superdirectory outside this one. 

## Part 1: Notes on Protein Annotation and Functional Mapping
For the 56 SAGs analyzed by Swan et al., we used Prodigal to identify protein-coding genes as the authors did, the script for doing so is `scripts/Prodigal-1.sh`. 

The authors utilized several utilities for mapping functional genes: the NCBI nonredundant database (nr), UniProt, TIGRfam, Pfam, KEGG, COG, and InterPro. We used the BLASTp utility to find functional orthologs in nr, as well as a utility (eggNOG v2.0) for functional mapping that did not exist at the time of publication.

## Part 2: Cory

## GC Content
# scripts: get_GC.sh, GC_plot.R

The 'get_GC.sh' bash script calculates GC content by dividing the grepped count of G+C nucleotides divided by the count of all ATGC nucleotides. The script does this count
for five groups of input files: genomic SAG's, SAG coding regions (CDS), genomic cultures, culture coding regions, and the filtered metagenomes; the GC contents are printed
in five corresponding files in the /output/genome_stats folder. 

The R script 'GC_plot.R' then plots these GC contents as five boxplots. 'GC_plot.R' also performs t-tests between these lists to check for significant differences in GC content between groups.


## Genome Size estimation and paralogs
# Scripts: get_genome_size.sh, busco_script.sh, parse_busco.sh, BlastClust.sh, get_paralogs.sh, para_plot.R

The bash script 'get_genome_size.sh' simply counts the number of nucleotides in all SAG and cultured genome fasta files.

Genome assembly completeness was assessed using the Benchmarking set of Unviersal Single-Copy Orthologs (BUSCO). The BUSCO databases for bacteria, actinobacteria, bacteroidetes,
proteobacteria, and gammaproteobacteria were downloaded and stored in our (unpushed) data folder, although only the bacteria database is needed to reproduce my figures. BUSCO was downloaded and installed in the envs/ folder, although it's not a conda environment.
In order to set up the program, I modified the config.ini file with the paths to the HPC modules of tblastn, hmmer, and ausgustus. 

The 'busco_script.sh' bash script first performs BUSCO analysis on all SAG genomes against the bacteria BUSCO database in nucleotide mode. Then, if a SAG belongs to a group for which a more specific database is available (ie. actinobacteria),
it performs the analysis for that SAG using that database. Then it repeats this for the predicted proteins using BUSCO in protein mode. 
The bash script 'parse_busco.sh' parses the BUSCO output and prints the ID, database, and percent of complete orthologs of each SAG and cul

Following the procedures of Swan et al. (2013), the script 'BlastClust.sh' writes clusters of 'paralogs' based on sequence similarity (in output/blastclust/).
It does this for SAG's and cultures. The bash script 'get_paralogs.sh' then reports the number of proteins that are in a cluster with at least one other protein, divided by the total number of predicted proteins.

Finally, the R script 'para_plot.R' uses the BUSCO results and SAG assembly sizes to estimate the size of the organism's actual genome. It plots these estimated genome sizes (as well as the actual cultured genome sizes) against the estimated number of 'paralogs' for each genome. 
It also uses an ANOVA test to test whether the regression lines for SAG's and cultures have different slopes (they do). 

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
